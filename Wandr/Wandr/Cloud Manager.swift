//
//  Cloud Manager.swift
//  Wandr
//
//  Created by C4Q on 2/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//
import Foundation
import CloudKit
import UIKit

//TODO List

/*
 _friends
 _user picture/user name/update posts locally -- i should've done this from the get go. That was poor thinking.
 _
 */

enum PostContentType: NSString {
    case audio, text, video
}

enum PrivacyLevel: NSString {
    case message = "Message"
    case friends = "Friends"
    case everyone = "Everyone"
}

class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    
    var currentUser: CKRecordID?
    
    func createPost (post: WanderPost, completion: @escaping (CKRecord?, Error?) -> Void) {
        
        //Update user at the same time
        let recordType = "post"
        //init set the information of the record
        
        let postRecord = CKRecord(recordType: recordType)
        switch post.contentType {
        case .text:
            guard let text = post.content as? NSString else {
                print ("invalid content")
                return
            }
            postRecord.setObject(text, forKey: "content")
            
        case .audio:
            guard let text = post.content as? CKAsset else {
                print ("invalid content")
                return
            }
            postRecord.setObject(text, forKey: "content")
            
        case .video:
            guard let text = post.content as? NSString else {
                print ("invalid content")
                return
            }
            postRecord.setObject(text, forKey: "content")
        }
        
        postRecord.setObject(post.location, forKey: "location")
        postRecord.setObject(NSString(string: post.user.recordName), forKey: "userID")
        postRecord.setObject(post.contentType.rawValue, forKey: "contentType")
        postRecord.setObject(post.privacyLevel.rawValue, forKey: "privacyLevel")
        
        let userFetch = CKFetchRecordsOperation(recordIDs: [post.user])
        let userSave = CKModifyRecordsOperation()
        //userFetch = CKFetchRecordsOperation(
        
        userFetch.fetchRecordsCompletionBlock = { (record, error) in
            if error != nil {
                if let ckError = error as? CKError  {
                    //TODO Add retry logic
                } else {
                    print(error!.localizedDescription)
                }
            }
            if let validRecord = record?.first {
                
                
                //Fix this.
                //Update the posts array
                let userRecord = validRecord.value
                var posts = userRecord["posts"] as? [NSString] ?? []
                posts.append(postRecord.recordID.recordName as NSString)
                userRecord["posts"] = posts as CKRecordValue?
                print(posts )
                
                //Save and post the record
                userSave.recordsToSave = [userRecord]
            }
        }
        
        //Init the userSave (to save the post)
        userSave.modifyRecordsCompletionBlock = {(records, recordIDs, errors) in
            if errors == nil, records?.count == 2 {
                _ = records?.map {
                    if $0.recordType == recordType {
                        print("working")
                        completion($0, nil)
                    }
                }
            } else {
                completion(nil, errors)
            }
        }
        let savePost = CKDatabaseOperation()
        savePost.container = self.container
        savePost.container?.publicCloudDatabase.save(postRecord) { (record, error) in
            completion(record, error)
        }
        
        userSave.addDependency(userFetch)
        userSave.addDependency(savePost)
        savePost.addDependency(userFetch)
        savePost.addDependency(userSave)
        
        let queue = OperationQueue()
        queue.addOperations([userFetch, userSave, savePost], waitUntilFinished: false)
    }
    
    func createUsername (userName: String, profileImageFilePathURL: URL, completion: @escaping (Error?) -> Void) {
        
        let validUsername = userName as NSString
        let id = CKRecordID(recordName: currentUser!.recordName)
        let imageAsset = CKAsset(fileURL: profileImageFilePathURL)
        
        publicDatabase.fetch(withRecordID: id) { (userRecord, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if let validUserRecord = userRecord {
                validUserRecord["username"] = validUsername
                validUserRecord["profileImage"] = imageAsset
                
                self.publicDatabase.save(validUserRecord) { (record, error) in
                    completion(error)
                }
            }
        }
    }
    
    func getCurrentUser() {
        self.container.fetchUserRecordID() { recordID, error in
            switch error {
            case .some:
                print(error!.localizedDescription)
            case .none:
                print("fetched ID \(recordID?.recordName)")
                self.currentUser = recordID
            }
        }
    }
    
    func getUserProfilePic(completion: @escaping (Data?, Error?) -> Void) {
        publicDatabase.fetch(withRecordID: self.currentUser!) { (record, error) in
            if error != nil {
                completion(nil, error)
            } else if let validRecord = record,
                let imageAsset = validRecord["profileImage"] as? CKAsset{
                do {
                    let data = try Data(contentsOf: imageAsset.fileURL)
                    completion(data, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    func checkUser () {
        let userID = CKRecordID(recordName: self.currentUser!.recordName)
        publicDatabase.fetch(withRecordID: userID) { (record, error) in
            if let error = error {
                guard let ckError = error as? CKError else {
                    print(error.localizedDescription)
                    return
                }
                print("\n\n error info \n\n")
                dump(ckError.userInfo)
            }
            if let record = record {
                print("\n\n record \n\n")
                dump(record)
            }
        }
    }
    
    func getWanderpostsForMap (_ currentLocation: CLLocation, completion: @escaping ([WanderPost]?, Error?) -> Void) {
        let locationSorter = CKLocationSortDescriptor(key: "location", relativeLocation: currentLocation)
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < 200", currentLocation)
        let query = CKQuery(recordType: "post", predicate: locationPredicate)
        query.sortDescriptors = [locationSorter]
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                completion(nil, error)
            }
            
            if let validLocalRecords = records {
                completion(validLocalRecords.map{ WanderPost(withCKRecord: $0)! }, nil)
                
            }
        }
    }
}

/*
 func fixPostCount() {
 let userFetch = CKFetchRecordsOperation(recordIDs: [CloudManager.shared.currentUser!])
 let userSave = CKModifyRecordsOperation()
 
 userFetch.fetchRecordsCompletionBlock = { (record, error) in
 if error != nil {
 if let ckError = error as? CKError  {
 //TODO Add retry logic
 } else {
 print(error!.localizedDescription)
 }
 }
 if let validRecord = record?.first {
 
 
 //Fix this.
 //Update the posts array
 let userRecord = validRecord.value
 var posts: [NSString] =  []
 userRecord["posts"] = posts as CKRecordValue?
 
 //Save and post the record
 userSave.recordsToSave = [userRecord]
 }
 }
 
 userSave.modifyRecordsCompletionBlock = {(records, recordIDs, errors) in
 }
 
 let queue = OperationQueue()
 queue.addOperations([userFetch, userSave], waitUntilFinished: false)
 }
 */

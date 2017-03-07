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
    case message = "message"
    case friends = "friends"
    case everyone = "everyone"
}

class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    
    var currentUser: CKRecordID?
    
    func createPost (post: WanderPost, completion: @escaping (CKRecord?, [Error]?) -> Void) {
        
        //Update user at the same time
        var completionRecord: CKRecord? = nil
        var completionError: [Error]? = nil
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
        postRecord.setObject(post.locationDescription as CKRecordValue?, forKey: "locationDescription")
        postRecord.setObject(post.read as CKRecordValue?, forKey: "read")
        
        let privateUserFetch = CKFetchRecordsOperation(recordIDs: [post.user])
        let publicUserFetch = CKFetchRecordsOperation(recordIDs: [post.user])
        let privateUserSave = CKModifyRecordsOperation()
        let publicPostsToSave = CKModifyRecordsOperation()
        
        privateUserFetch.database = privateDatabase
        privateUserSave.database = privateDatabase
        
        publicUserFetch.database = self.publicDatabase
        publicPostsToSave.database = self.publicDatabase
        
        privateUserFetch.fetchRecordsCompletionBlock = { (record, error) in
            if error != nil {
                completionError?.append(error!)
                if let ckError = error as? CKError  {
                    //TODO Add retry logic
                } else {
                    print(error!.localizedDescription)
                }
            }
            
            if let validRecord = record?.first {
                //Fix this.
                //Update the posts array
                let userRecord = self.addPost(to: validRecord.value, value: postRecord.recordID.recordName)
                //Save and post the record
                privateUserSave.recordsToSave = [userRecord]
            }
        }
        
        publicUserFetch.fetchRecordsCompletionBlock = { (record, error) in
            if error != nil {
                completionError?.append(error!)
                if let ckError = error as? CKError  {
                    //TODO Add retry logic
                } else {
                    print(error!.localizedDescription)
                }
            }
            
            if let validRecord = record?.first {
                //Fix this.
                //Update the posts array
                let userRecord = self.addPost(to: validRecord.value, value: postRecord.recordID.recordName)
                //Save and post the record
                publicPostsToSave.recordsToSave = [userRecord, postRecord]
            }
        }

        //Init the userSave (to save the post)
        privateUserSave.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
            if error != nil {
                completionError?.append(error!)
            }
        }
        publicPostsToSave.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
            
            
            if error != nil {
                completionError?.append(error!)
            }
            if let validRecords = records {
                
                _ = validRecords.map {
                    if $0.recordType == recordType {
                        completionRecord = $0
                    }
                }
            }
        }

        
        privateUserSave.addDependency(privateUserFetch)
        privateUserSave.addDependency(publicUserFetch)
        publicPostsToSave.addDependency(privateUserFetch)
        publicPostsToSave.addDependency(publicUserFetch)
        
        privateUserFetch.queuePriority = .veryHigh
        publicUserFetch.queuePriority = .veryHigh
        
        let queue = OperationQueue.main
        queue.addOperations([privateUserFetch, publicUserFetch, privateUserSave, publicPostsToSave], waitUntilFinished: false)
        queue.addOperation { 
            completion(completionRecord, completionError)
        }
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
    
    func checkUser (completion: @escaping (Bool, Error?) -> Void) {
        let userID = CKRecordID(recordName: self.currentUser!.recordName)
        publicDatabase.fetch(withRecordID: userID) { (record, error) in
            if let error = error {
                guard let ckError = error as? CKError else {
                    print(error.localizedDescription)
                    completion(false, error)
                    return
                }
                print("\n\n error info \n\n")
                dump(ckError.userInfo)
            }
            if let record = record {
                print("\n\n record \n\n")
                completion(true, nil)
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
    
    func getUserPostActivity (completion: @escaping ([String]?, Error?) -> Void) {
        privateDatabase.fetch(withRecordID: self.currentUser!) { (record, error) in
            if error != nil {
                completion(nil, error)
            }
            if let validRecord = record,
                let posts = validRecord["posts"] as? [String] {
                completion(posts, nil)
                
            }
        }
    }
    
    //MARK: Helper Functions
    private func addPost(to record: CKRecord, value: String) -> CKRecord {
        let userRecord = record
        var posts = userRecord["posts"] as? [NSString] ?? []
        posts.append(value as NSString)
        userRecord["posts"] = posts as CKRecordValue?
        return userRecord
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
        userSave.addDependency(userFetch)
        let queue = OperationQueue()
        queue.addOperations([userFetch, userSave], waitUntilFinished: false)
    }
 */

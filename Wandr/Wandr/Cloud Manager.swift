//
//  Cloud Manager.swift
//  Wandr
//
//  Created by C4Q on 2/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//
import Foundation
import CloudKit

enum PostContentType: NSString {
    case audio, text, video
}

enum PrivacyLevel: NSString {
    case message = "Message"
    case friends = "Friends"
    case everyone = "Everyone"
}

class PrivacyLevelManager {
    static let shared = PrivacyLevelManager()
    let privacyLevelArray: [PrivacyLevel] = {
        return [PrivacyLevel.everyone, PrivacyLevel.friends, PrivacyLevel.message]
    }()
    
    let privacyLevelStringArray: [String] = {
        let privacyLevel =  [PrivacyLevel.everyone, PrivacyLevel.friends, PrivacyLevel.message]
        return privacyLevel.map{ ($0.rawValue as String) }
    }()
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
        postRecord.setObject(NSString(string: post.user!.recordName), forKey: "userID")
        postRecord.setObject(post.contentType.rawValue, forKey: "contentType")
        postRecord.setObject(post.privacyLevel.rawValue, forKey: "privacyLevel")

        let userFetch = CKFetchRecordsOperation(recordIDs: [post.user!])
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
    //This doesn't really work, I need to pull the existing user file and update it, not try and create a new one. This is especially useful because this is how I am going to be updating friends and posts.
    func createUsername (userName: String, completion: @escaping (Error?) -> Void) {
        
        let validUsername = userName as NSString
        let id = CKRecordID(recordName: currentUser!.recordName)
        
        publicDatabase.fetch(withRecordID: id) { (userRecord, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if let validUserRecord = userRecord
            {
                validUserRecord["username"] = validUsername
                
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
    
    func checkUsername () {
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
    
    func getWanderpostsForMap (_ currentLocation: CLLocation, privacyLevel: PrivacyLevel) {
        
        let locationSorter = CKLocationSortDescriptor(key: "location", relativeLocation: currentLocation)
        
        let radius = 1000
        
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", currentLocation, radius)
        let query = CKQuery(recordType: "post", predicate: locationPredicate)
        query.sortDescriptors = [locationSorter]
        let fetchInLocation = CKQueryOperation(query: query)
        
        fetchInLocation.queryCompletionBlock = {(query, error) in
            
        }
        
        let queue = OperationQueue()
        queue.addOperation(fetchInLocation)
        
    }
}

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
    case message, friends, everyone
}


class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
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

        let userFetch = CKFetchRecordsOperation(recordIDs: [post.user!])
        let postSave = CKModifyRecordsOperation()

        userFetch.fetchRecordsCompletionBlock = { (record, error) in
            if error != nil {
                if let ckError = error as? CKError  {
                    ckError.userInfo[CKErrorRetryAfterKey]
                } else {
                    print(error!.localizedDescription)
                }
            }
            if let validRecord = record?.first {
                
                //Update the posts array
                let userRecord = validRecord.value
                var posts = userRecord["posts"] as? [NSString] ?? []
                posts.append(postRecord.recordID.recordName as NSString)
                userRecord["posts"] = posts as CKRecordValue?
                
                //Save and post the record
                postSave.recordsToSave = [userRecord, postRecord]
            }
        }
        
        //Init the userSave (to save the post)
        postSave.modifyRecordsCompletionBlock = {(records, recordIDs, errors) in
            //add completion passer to 
            if errors == nil, records?.count == 2 {
                _ = records?.map {
                    if $0.recordType == recordType {
                        completion($0, nil)
                    }
                }
            } else {
                completion(nil, errors)
            }
        }
        
        postSave.addDependency(userFetch)
        let queue = OperationQueue()
        queue.addOperations([userFetch, postSave], waitUntilFinished: false)
    }
    //This doesn't really work, I need to pull the existing user file and update it, not try and create a new one. This is especially useful because this is how I am going to be updating friends and posts.
    func createUser (userName: String, completion: @escaping (Error?) -> Void) {
        
        let validUsername = userName as NSString
        let id = CKRecordID(recordName: currentUser!.recordName)
        let userRecord = CKRecord(recordType: "Users", recordID: id)
        
        userRecord.setObject(validUsername, forKey: "username")
        
        publicDatabase.save(userRecord) { (record, error) in
            completion(error)
        }
    }
    
    func getCurrentUser() {
        let container = CKContainer.default()
        container.fetchUserRecordID() { recordID, error in
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
}

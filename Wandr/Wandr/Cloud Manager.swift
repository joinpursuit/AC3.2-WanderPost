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
    case message
    case friends
    case everyone
}

enum ProfileViewFilterType: String {
    case posts = "posts"
    case feed = "feed"
    case messages = "messages"
}

class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    //Look into making this a wanderuser
    var currentUser: CKRecordID?
    
    
    //MARK: - Creating a Post and a User
    
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
                let userRecord = self.addValue(to: validRecord.value, key: "posts", value: postRecord.recordID.recordName)
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
                let userRecord = self.addValue(to: validRecord.value, key: "posts", value: postRecord.recordID.recordName)
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
    
    //MARK: - Checking User existance and pulling current User
    
    
    //Refactor this into one functions that gets the current user, make it a Wanderuser. if that fails, present the error, if the error is no user found, present the onboard screen
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
    
    //MARK: - Get Posts in Location
    
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
    
    //MARK: - Get User Activity and Information
    
    func getUserPostActivity (for id: CKRecordID, completion: @escaping ([WanderPost]?, Error?) -> Void) {
        privateDatabase.fetch(withRecordID: id) { (record, error) in
            if error != nil {
                completion(nil, error)
            }
            if let validRecord = record,
                let posts = validRecord["posts"] as? [String] {
                let postRecordIDs = posts.map { CKRecordID(recordName: $0) }
                let fetchPostsOperation = CKFetchRecordsOperation(recordIDs: postRecordIDs)
                
                fetchPostsOperation.fetchRecordsCompletionBlock = {(records, error) in
                    if error != nil {
                        completion(nil, error)
                    }
                    if let validRecords = records {
                        let postRecords = validRecords.values
                        
                        completion(postRecords.map { WanderPost(withCKRecord: $0)! }, nil)
                    }
                    
                }
                self.publicDatabase.add(fetchPostsOperation)
            }
        }
    }
    
    func getUserInfo(for id: CKRecordID, completion: @escaping (WanderUser?, Error?) -> Void) {
        
        publicDatabase.fetch(withRecordID: id) { (record, error) in
            if error != nil {
                completion(nil, error)
            }
            if let validRecord = record,
                let user = WanderUser(from: validRecord) {
                completion(user, nil)
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
    
    func getUserInfo (forPosts posts: [WanderPost], completion: @escaping (Error?) -> Void ) {
        let users = Set<CKRecordID>(posts.map{ $0.user })
        let fetchPostsOperation = CKFetchRecordsOperation(recordIDs: Array(users))
        
        fetchPostsOperation.fetchRecordsCompletionBlock = {(records, error) in
            if error != nil {
                completion(error)
            }
            if let validRecords = records?.values {
                for userRecord in validRecords {
                    let user = WanderUser(from: userRecord)!
                    let usersPosts = posts.filter { $0.user.recordName == user.id.recordName }
                    usersPosts.map { $0.wanderUser = user }
                }
                completion(nil)
            }
            
        }
        self.publicDatabase.add(fetchPostsOperation)

    }
    
    //MARK: - Friend Adding and Notifications
    
    func add(friend id: CKRecordID, completion: @escaping (Error?) -> Void ) {
        let fetchBothUsersOperation = CKFetchRecordsOperation(recordIDs: [id, self.currentUser!])        
        let saveFriendsToBothUsersOperation = CKModifyRecordsOperation()
        
        
        fetchBothUsersOperation.fetchRecordsCompletionBlock = {(recordDict, error) in
            if error != nil {
                completion(error)
            }
            if let validRecordDictionary = recordDict,
                let currentUser = validRecordDictionary[self.currentUser!],
                let friendAdded = validRecordDictionary[id] {
                let friendRecordOne = self.addValue(to: currentUser,
                                                    key: "friends",
                                                    value: id.recordName)
                let friendRecordTwo = self.addValue(to: friendAdded,
                                                    key: "friends",
                                                    value: self.currentUser!.recordName)
                
                saveFriendsToBothUsersOperation.recordsToSave = [friendRecordOne, friendRecordTwo]
            }
        }
        
        saveFriendsToBothUsersOperation.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
            completion(error)
        }
        
        saveFriendsToBothUsersOperation.addDependency(fetchBothUsersOperation)
        
        publicDatabase.add(fetchBothUsersOperation)
        publicDatabase.add(saveFriendsToBothUsersOperation)
    }
    
    func addSubscriptionToCurrentuser(completion: @escaping (Error?) -> Void ) {
        //let friendAddedSubscription = CKDatabaseSubscription(subscriptionID: "friendAdded")
        let predicate = NSPredicate(format: "friends CONTAINS %@", currentUser!.recordName)
        
        let friendAddedSubscription = CKQuerySubscription(recordType: "Users", predicate: predicate, options: .firesOnRecordUpdate)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "working"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        
        friendAddedSubscription.notificationInfo = notificationInfo
        
        
        
        publicDatabase.save(friendAddedSubscription) { (subscription, error) in
            
            print(subscription)
            print(error)
            
        }
    }
    
    //MARK: - Helper Functions
    private func addValue(to record: CKRecord, key: String, value: String) -> CKRecord {
        let mutableRecord = record
        var ids = mutableRecord[key] as? [NSString] ?? []
        
        
        if !ids.contains(value as NSString) {
            ids.append(value as NSString)
            print("addedFriend")
        } else {
            print("yall are already friends, don't be insecure")
            return record
        }
        mutableRecord[key] = ids as CKRecordValue?
        return mutableRecord
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

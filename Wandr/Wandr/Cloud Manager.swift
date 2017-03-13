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
 _ deleting form data base, this include comments, posts, friends
 _friend requests
 _error handling - check with jason the best way to go about retriggering the call
 _list of the users for friends
 
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
    
    var currentUser: WanderUser?
    
    
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
        let id = CKRecordID(recordName: currentUser!.id.recordName)
        let imageAsset = CKAsset(fileURL: profileImageFilePathURL)
        
        publicDatabase.fetch(withRecordID: self.currentUser!.id) { (userRecord, error) in
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
    func getCurrentUser(completion: @escaping (Error?)-> Void ) {
        
        let currentUserFetch = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
        currentUserFetch.fetchRecordsCompletionBlock = {(userRecord, error) in
            if error != nil {
                completion(error)
            }
            if let validUserRecord = userRecord?.values,
                let currentUser = validUserRecord.first {
                
                
                self.currentUser = WanderUser(from: currentUser)
                completion(nil)
            }
        }
        self.publicDatabase.add(currentUserFetch)
    }
    
    func checkUser (completion: @escaping (Bool, Error?) -> Void) {
        publicDatabase.fetch(withRecordID: self.currentUser!.id) { (record, error) in
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
                if let ckError = error as? CKError {
                    switch ckError.errorCode {
                    default:
                        break
                    }
                    if let retryTime = ckError.retryAfterSeconds {
                        
                    }
                }
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
        
    func getInfo(forPosts posts: [WanderPost], completion: @escaping (Error?) -> Void ) {
        let users = Set<CKRecordID>(posts.map{ $0.user })
        var reactionIDs = [CKRecordID]()
        
        for post in posts {
            reactionIDs += post.reactionIDs
        }
        
        let fetchPostsOperation = CKFetchRecordsOperation(recordIDs: users + reactionIDs)
        
        fetchPostsOperation.fetchRecordsCompletionBlock = {(records, error) in
            if error != nil {
                completion(error)
            }
            if let validRecords = records {
                
                for user in users {
                    if let validUserRecord = validRecords[user],
                        let user = WanderUser(from: validUserRecord) {
                        let usersPosts = posts.filter { $0.user.recordName == user.id.recordName }
                        usersPosts.map { $0.wanderUser = user }
                    } else if let user = CloudManager.shared.currentUser {
                        let usersPosts = posts.filter { $0.user.recordName == user.id.recordName }
                        usersPosts.map { $0.wanderUser = user }
                    }
                }
                
                var reactions = [CKRecordID: [Reaction]]()
                for reactionID in reactionIDs {
                    if let validReactionRecord = validRecords[reactionID],
                        let reaction = Reaction(from: validReactionRecord) {
                        
                        reactions[reaction.postID.recordID] = (reactions[reaction.postID.recordID] ?? []) + [reaction]
                    }
                }
                
                for post in posts {
                    if let postReactions = reactions[post.postID] {
                        
                        post.reactions = postReactions
                    }
                }
                completion(nil)
            }
        }
        
        
        self.publicDatabase.add(fetchPostsOperation)
        
    }
    
    //MARK: - Friend Adding and Notifications
    
    func add(friend id: CKRecordID, completion: @escaping (Error?) -> Void ) {
        let fetchBothUsersOperation = CKFetchRecordsOperation(recordIDs: [id, self.currentUser!.id])
        let saveFriendsToBothUsersOperation = CKModifyRecordsOperation()
        
        fetchBothUsersOperation.fetchRecordsCompletionBlock = {(recordDict, error) in
            if error != nil {
                completion(error)
            }
            if let validRecordDictionary = recordDict,
                let currentUser = validRecordDictionary[self.currentUser!.id],
                let friendAdded = validRecordDictionary[id] {
                let friendRecordOne = self.addValue(to: currentUser,
                                                    key: "friends",
                                                    value: id.recordName)
                let friendRecordTwo = self.addValue(to: friendAdded,
                                                    key: "friends",
                                                    value: self.currentUser!.id.recordName)
                
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
        let predicate = NSPredicate(format: "friends CONTAINS %@", currentUser!.id.recordName)
        
        let friendAddedSubscription = CKQuerySubscription(recordType: "Users", predicate: predicate, options: .firesOnRecordUpdate)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = "\(self.currentUser)"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        
        friendAddedSubscription.notificationInfo = notificationInfo
        
        publicDatabase.save(friendAddedSubscription) { (subscription, error) in
            completion(error)
        }
    }
    
    //MARK:  - Adding a comment
    
    func addReaction(to post: WanderPost, comment: Reaction, completion: @escaping (Error?) -> Void) {
        
        //create the comment
        //Tom needs the userID, the the comment, the time,
        let commentRecord = CKRecord(recordType: "comment")
        
        commentRecord.setObject(comment.type.rawValue, forKey: "type")
        commentRecord.setObject(comment.content as NSString, forKey: "content")
        commentRecord.setObject(comment.userID.recordName as NSString, forKey: "userID")
        
        let postRecordFetch = CKFetchRecordsOperation(recordIDs: [post.postID])
        let saveCommentRecords = CKModifyRecordsOperation()
        
        postRecordFetch.fetchRecordsCompletionBlock = {(record, error) in
            if error != nil {
                completion(error)
            }
            
            if let postRecord = record?[post.postID] {
                //let parentReference = CKReference(record: postRecord, action: .deleteSelf)
                commentRecord.setObject(comment.postID, forKey: "postID")
                
                let modifiedRecord = self.addValue(to: postRecord, key: "reactions", value: commentRecord.recordID.recordName)
                saveCommentRecords.recordsToSave = [modifiedRecord, commentRecord]
            }
        }
        
        saveCommentRecords.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
            completion(error)
        }
        
        saveCommentRecords.addDependency(postRecordFetch)
        publicDatabase.add(postRecordFetch)
        publicDatabase.add(saveCommentRecords)
    }
    
    //MARK: - Helper Functions
    private func addValue(to record: CKRecord, key: String, value: String) -> CKRecord {
        let mutableRecord = record
        var ids = mutableRecord[key] as? [NSString] ?? []
        if !ids.contains(value as NSString) {
            ids.append(value as NSString)
        } else {
            return record
        }
        mutableRecord[key] = ids as CKRecordValue?
        return mutableRecord
    }
    
    
    //MARK: - Deleting From Database
    func delete(friend id: CKRecordID, completion: @escaping (Error?) -> Void ) {
        let fetchUsers = CKFetchRecordsOperation(recordIDs: [self.currentUser!.id, id])
        let updateFriendsLists = CKModifyRecordsOperation()
        fetchUsers.fetchRecordsCompletionBlock = {(userRecords, error) in
            
            if error != nil {
                completion(error)
            }
            
            if let validUserRecords = userRecords?.values,
                validUserRecords.count == 2 {
                let userOne = validUserRecords[validUserRecords.startIndex]
                let userTwo = validUserRecords[validUserRecords.index(after: validUserRecords.startIndex)]
                
                if let userOneFriends = userOne["friends"] as? [String],
                    let userTwoFriends = userTwo["friends"] as? [String] {
                    let userOneUpdatedFriends = userOneFriends.filter { $0 != userTwo.recordID.recordName }
                    let userTwoUpdatedFriends = userTwoFriends.filter { $0 != userOne.recordID.recordName }
                    
                    userOne["friends"] = userOneUpdatedFriends as CKRecordValue?
                    userTwo["friends"] = userTwoUpdatedFriends as CKRecordValue?
                    
                    updateFriendsLists.recordsToSave = [userOne, userTwo]
                }
            }
        }
        
        updateFriendsLists.modifyRecordsCompletionBlock = {(record, recordID, error) in
            completion(error)
        }
        
        updateFriendsLists.addDependency(fetchUsers)
        
        publicDatabase.add(fetchUsers)
        publicDatabase.add(updateFriendsLists)
    }
    
    func delete(wanderpost post: WanderPost, completion: @escaping (Error?) -> Void ) {
        let fetchPublicUsers = CKFetchRecordsOperation(recordIDs: [post.user])
        let fetchPrivateUsers = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
        let deletePublicPost = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [post.postID])
        let deletePrivatePost = CKModifyRecordsOperation()
        
        let fetchCompletionBlock = { (database: CKModifyRecordsOperation, records: [CKRecordID: CKRecord]?, error: Error?) in
            
            if error != nil {
                completion(error)
            }
            if let record = records?.values.first {
                
                guard let posts = record["posts"] as? [String],
                    posts.contains(post.postID.recordName) else {
                        completion(error)
                        return
                }
                
                let updatedPosts = posts.filter{ $0 != post.postID.recordName }
                print(updatedPosts)
                record["posts"] = updatedPosts as CKRecordValue?
                database.recordsToSave = (database.recordsToSave ?? []) + [record]
            }
        }
        
        
        fetchPublicUsers.fetchRecordsCompletionBlock = {(records, error) in
            fetchCompletionBlock(deletePublicPost, records, error)
        }
        fetchPrivateUsers.fetchRecordsCompletionBlock = { (records: [CKRecordID: CKRecord]?, error: Error?) in
            fetchCompletionBlock(deletePrivatePost, records, error)
            
        }
        
        deletePublicPost.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
            completion(error)
        }
        deletePrivatePost.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
            completion(error)
        }
        
        fetchPrivateUsers.addDependency(fetchPublicUsers)
        deletePublicPost.addDependency(fetchPrivateUsers)
        deletePrivatePost.addDependency(deletePublicPost)
        
        privateDatabase.add(fetchPrivateUsers)
        publicDatabase.add(fetchPublicUsers)
        publicDatabase.add(deletePublicPost)
        privateDatabase.add(deletePrivatePost)
    }
}

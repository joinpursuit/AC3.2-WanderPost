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

//TODO: List

/*
 _friend requests
 _error handling - check with jason the best way to go about retriggering the call/present alerts for when they fail with user appropriate descriptions of what happened.
 _personal website
 _make the push notification trigger a notification with the correct data/rewrite the userinfo to have the right information before making the CKNotification
 */

//Update users when friends added

//Consider putting this in the model for user, etc. so that i don't have to retype the calling of the functions


enum PrivacyLevel: String {
    case personal
    case friends
    case everyone
    
    static func ordered() -> [PrivacyLevel] {
        return [.everyone, .friends, .personal]
    }
    
    static func orderedStrings() -> [String] {
        return ordered().map { return $0.rawValue }
    }
}

enum ProfileViewFilterType: String {
    case posts
    case feed
    case personal
    
    func segmentIndex() -> Int {
        return ProfileViewFilterType.order().index(of: self)!
    }
    
    static func order() -> [ProfileViewFilterType] {
        return [.feed, .posts, .personal]
    }
    static func orderedStrings() -> [String] {
        return order().map { return $0.rawValue }
    }
}

enum RecordType: String {
    case comment
    case user
    case post
    case username
    case users = "Users"
}

enum PostContentType: String {
    case audio
    case text
    case video
}

protocol KeyNames {
    var key: String { get }
}

enum PostRecordKeyNames: String, KeyNames {
    case content
    case location
    case contentType
    case privacyLevel
    case locationDescription
    case read
    case posts
    case recipient
    case userID
    case reactions
    case postID
    
    var key: String {
        return self.rawValue
    }
}

enum UserRecordKeyNames: String, KeyNames  {
    case username
    case profileImage
    case friends
    case posts
    
    var key: String {
        return self.rawValue
    }
}

enum CommentRecordKeyNames: String, KeyNames {
    case content
    case type
    case postID
    case userID
    
    var key: String {
        return self.rawValue
    }
}

enum UsernameRecordKeyNames: String, KeyNames {
    case username
    
    var key: String {
        return self.rawValue
    }
}

class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let container = CKContainer.default()
    
    //This could be implicitly unwrapped, look into refactoring -- specifically in profileview controller there is a useless guard statement. Now is the time to look into handling the alert.
    
    var currentUser: WanderUser?
    
    //MARK: - Creating a Post and a User
    
    func createPost (post: WanderPost, to: WanderUser?,  completion: @escaping (CKRecord?, [Error]?) -> Void) {
        //Update user at the same time
        var completionRecord: CKRecord? = nil
        var completionError: [Error]? = nil
        //init set the information of the record
        
        let postRecord = CKRecord(recordType: RecordType.post.rawValue)
        
        switch post.contentType {
        case .text:
            guard let text = post.content as? NSString else {
                return
            }
            postRecord[PostRecordKeyNames.content.key] = text
            
        case .audio:
            guard let text = post.content as? CKAsset else {
                print ("invalid content")
                return
            }
            postRecord[PostRecordKeyNames.content.key] = text
            
        case .video:
            guard let text = post.content as? NSString else {
                print ("invalid content")
                return
            }
            postRecord[PostRecordKeyNames.content.key] = text
        }
        
        postRecord[PostRecordKeyNames.location.key] = post.location
        postRecord[PostRecordKeyNames.userID.key] = post.user.recordName as CKRecordValue
        postRecord[PostRecordKeyNames.contentType.key] = post.contentType.rawValue as CKRecordValue
        postRecord[PostRecordKeyNames.privacyLevel.key] = post.privacyLevel.rawValue as CKRecordValue
        postRecord[PostRecordKeyNames.locationDescription.key] = post.locationDescription as CKRecordValue
        postRecord[PostRecordKeyNames.read.key] = post.read as CKRecordValue?
        
        if let validRecipient = to {
            postRecord.setObject(validRecipient.id.recordName as CKRecordValue?, forKey: PostRecordKeyNames.recipient.key)
        }
        
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
            }
            
            if let validRecord = record?.first {
                //Fix this.
                //Update the posts array
                let userRecord = self.updateValue(on: validRecord.value, for: PostRecordKeyNames.posts, value: postRecord.recordID.recordName)
                //Save and post the record
                privateUserSave.recordsToSave = [userRecord]
            }
        }
        
        publicUserFetch.fetchRecordsCompletionBlock = { (record, error) in
            if error != nil {
                completionError?.append(error!)
            }
            
            if let validRecord = record?.first {
                let userRecord = self.updateValue(on: validRecord.value, for: PostRecordKeyNames.posts, value: postRecord.recordID.recordName)
                //Save and post the record
                publicPostsToSave.recordsToSave = [userRecord, postRecord]
            }
        }
        
        //Init the userSave (to save the postID to the private user, this might just be a mistake at this point, because the users aren't accessible, this is only used for logging in privacy. the rest of the user data is public. I think we might not need this. I'll talk to them about it)
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
                    if $0.recordType == RecordType.post.rawValue {
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
    
    func createUsername(userName: String, profileImageFilePathURL: URL, completion: @escaping (Error?) -> Void) {
        
        let imageAsset = CKAsset(fileURL: profileImageFilePathURL)
        let usernameRecord = CKRecord(recordType: RecordType.user.rawValue)
        let validUsername = userName as NSString
        
        container.fetchUserRecordID {(record, error) in
            
            if error != nil {
                completion(error)
            }
            if let userRecord = record {
                self.publicDatabase.fetch(withRecordID: userRecord) { (userRecord, error) in
                    if error != nil {
                        completion(error)
                    } else if let validUserRecord = userRecord {
                        usernameRecord[UsernameRecordKeyNames.username.key] = validUsername
                        validUserRecord[UserRecordKeyNames.username.key] = validUsername
                        validUserRecord[UserRecordKeyNames.profileImage.key] = imageAsset
                        
                        let saveUser = CKModifyRecordsOperation()
                        
                        saveUser.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
                            completion(error)
                        }
                        
                        saveUser.recordsToSave = [validUserRecord, usernameRecord]
                        self.publicDatabase.add(saveUser)
                    }
                }
            }
        }
    }
    
    //MARK: - Checking User existance and pulling current User
    
    //Refactor this into one functions that gets the current user, make it a Wanderuser. if that fails, present the error, if the error is no user found, present the onboard screen
    func getCurrentUser(completion: @escaping (Bool, Error?)-> Void ) {
        
        let currentUserFetch = CKFetchRecordsOperation.fetchCurrentUserRecordOperation()
        currentUserFetch.fetchRecordsCompletionBlock = {(userRecord, error) in
            
            if error != nil {
                completion(false, error)
            }
            
            if let validUserRecord = userRecord?.values,
                let currentUser = validUserRecord.first,
                let validUser = WanderUser(from: currentUser) {
                self.currentUser = validUser
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
        self.publicDatabase.add(currentUserFetch)
    }
    
    func checkUsernameAvailability (_ username: String, completion: @escaping (Bool, Error?) -> Void ) {
        
        let predicate = NSPredicate(format: "username == %@", username)
        let usernameQuery = CKQuery(recordType: RecordType.username.rawValue, predicate: predicate)
        
        publicDatabase.perform(usernameQuery, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                completion(false, error)
            }
            if records?.count == 0 {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    //MARK: - Search data base for users, posts
    
    func getWanderpostsForMap (_ currentLocation: CLLocation, completion: @escaping ([WanderPost]?, Error?) -> Void) {
        let locationSorter = CKLocationSortDescriptor(key: "location", relativeLocation: currentLocation)
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < 100", currentLocation)
        let query = CKQuery(recordType: RecordType.post.rawValue, predicate: locationPredicate)
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
    
    func search(for user: String, completion: @escaping ([WanderUser]?, Error?) -> Void) {
        let predicate = NSPredicate(format: "username BEGINSWITH %@", user)
        let usernameQuery = CKQuery(recordType: RecordType.username.rawValue, predicate: predicate)
        let fetchUserInfo = CKFetchRecordsOperation()
        
        publicDatabase.perform(usernameQuery, inZoneWith: nil) { (records, error) in
            
            if error != nil {
                completion(nil, error)
            }
            
            if let validRecords = records,
                validRecords.count > 0 {
                let userRecordIDs: [CKRecordID] = validRecords.map { $0.creatorUserRecordID! }
                
                fetchUserInfo.recordIDs = userRecordIDs
                fetchUserInfo.fetchRecordsCompletionBlock = {(recordsDictionary, error) in
                    if error != nil {
                        completion(nil, error)
                    }
                    if let records = recordsDictionary?.values {
                        let users: [WanderUser] = records.map { WanderUser(from: $0)! }
                        completion(users, nil)
                    }
                }
                self.publicDatabase.add(fetchUserInfo)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func findPrivateMessages (for user: WanderUser, completion: @escaping ([WanderPost]?, Error?)-> Void ) {
        let privateMessagePredicate = NSPredicate(format: "recipient = %@", user.id.recordName)
        let privateMessageQuery = CKQuery(recordType: RecordType.post.rawValue, predicate: privateMessagePredicate)
        publicDatabase.perform(privateMessageQuery, inZoneWith: nil) { (records, error) in
            if error != nil {
                completion(nil, error)
            }
            if let validPrivateMessageRecords = records {
                let privateMessages = validPrivateMessageRecords.map { WanderPost(withCKRecord: $0)! }
                completion(privateMessages, nil)
            }
        }
    }
    
    //MARK: - Get User Activity and Information
    
    func getUserPostActivity (for id: CKRecordID, completion: @escaping ([WanderPost]?, Error?) -> Void) {
        publicDatabase.fetch(withRecordID: id) { (record, error) in
            if error != nil {
                completion(nil, error)
            }
            if let validRecord = record,
                let posts = validRecord[PostRecordKeyNames.posts.key] as? [String] {
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
            }        }
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
    
    func getInfo(forUsers users: [CKRecordID], completion: @escaping ([WanderUser]?, Error?) -> Void ) {
        let fetchUsers = CKFetchRecordsOperation(recordIDs: users)
        fetchUsers.fetchRecordsCompletionBlock = {(records, error) in
            if error != nil {
                completion(nil, error)
            }
            if let fetchedUserRecords = records?.values {
                let wanderUsers: [WanderUser] = fetchedUserRecords.map { WanderUser(from: $0)! }
                completion(wanderUsers, nil)
            }
        }
        publicDatabase.add(fetchUsers)
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
                        _ = usersPosts.map { $0.wanderUser = user }
                    } else if user.recordName == "__defaultOwner__", let currentUser = CloudManager.shared.currentUser {
                        let usersPosts = posts.filter { $0.user.recordName == "__defaultOwner__" }
                        _ = usersPosts.map { $0.wanderUser = currentUser }
                    }
                }
                
                var reactions = [CKRecordID: [WanderReaction]]()
                for reactionID in reactionIDs {
                    if let validReactionRecord = validRecords[reactionID],
                        let reaction = WanderReaction(from: validReactionRecord) {
                        
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
                let friendRecordOne = self.updateValue(on: currentUser,
                                                       for: UserRecordKeyNames.friends,
                                                    value: id.recordName)
                let friendRecordTwo = self.updateValue(on: friendAdded,
                                                       for: UserRecordKeyNames.friends,
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
    
    func addSubscriptionToCurrentUser(completion: @escaping (Error?) -> Void ) {
        let predicate = NSPredicate(format: "friends CONTAINS %@", currentUser!.id.recordName)
        
        let friendAddedSubscription = CKQuerySubscription(recordType: RecordType.users.rawValue, predicate: predicate, subscriptionID: "friendAdded", options: .firesOnRecordDeletion)
        
        let notificationInfo = CKNotificationInfo()
        let currentUsername = self.currentUser!.username
        notificationInfo.alertBody = currentUsername + " has added you as a friend!"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        
        friendAddedSubscription.notificationInfo = notificationInfo
        
        publicDatabase.save(friendAddedSubscription) { (subscription, error) in
            completion(error)
        }
    }
    
    func addSubscriptionForPersonalPosts (completion: @escaping (Error?) -> Void ) {
        let predicate = NSPredicate(format: "recipient == %@", self.currentUser!.id.recordName)
        
        let personalPostSubscription = CKQuerySubscription(recordType: RecordType.post.rawValue, predicate: predicate, subscriptionID: "personalPost", options: .firesOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        
        notificationInfo.alertBody = "Somebody has left you a message!"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        
        personalPostSubscription.notificationInfo = notificationInfo
        
        publicDatabase.save(personalPostSubscription) { (subscription, error) in
            completion(error)
        }
    }
    
    //MARK:  - Adding a comment
    func addReaction(to post: WanderPost, comment: WanderReaction, completion: @escaping (Error?) -> Void) {
        
        let commentRecord = CKRecord(recordType: RecordType.comment.rawValue)
        
        commentRecord[CommentRecordKeyNames.type.key] = comment.type.rawValue
        commentRecord[CommentRecordKeyNames.content.key] = comment.content as CKRecordValue
        commentRecord[CommentRecordKeyNames.userID.key] = comment.userID.recordName as CKRecordValue
        commentRecord[CommentRecordKeyNames.postID.key] = comment.postID
        
        let postRecordFetch = CKFetchRecordsOperation(recordIDs: [post.postID])
        let saveCommentRecords = CKModifyRecordsOperation()
        
        postRecordFetch.fetchRecordsCompletionBlock = {(record, error) in
            if error != nil {
                completion(error)
            }
            
            if let postRecord = record?[post.postID] {
                let modifiedRecord = self.updateValue(on: postRecord,
                                                      for: PostRecordKeyNames.reactions,
                                                      value: commentRecord.recordID.recordName)
                
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
    private func updateValue(on record: CKRecord, for key: KeyNames, value: String) -> CKRecord {
        let mutableRecord = record
        var valueToUpdate = mutableRecord[key.key] as? [NSString] ?? []
        if !valueToUpdate.contains(value as NSString) {
            valueToUpdate.append(value as NSString)
        } else {
            return record
        }
        mutableRecord[key.key] = valueToUpdate as CKRecordValue?
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
                
                if let userOneFriends = userOne[UserRecordKeyNames.friends.key] as? [String],
                    let userTwoFriends = userTwo[UserRecordKeyNames.friends.key] as? [String] {
                    
                    let userOneUpdatedFriends = userOneFriends.filter { $0 != userTwo.recordID.recordName }
                    let userTwoUpdatedFriends = userTwoFriends.filter { $0 != userOne.recordID.recordName }
                    
                    userOne[UserRecordKeyNames.friends.key] = userOneUpdatedFriends as CKRecordValue?
                    userTwo[UserRecordKeyNames.friends.key] = userTwoUpdatedFriends as CKRecordValue?
                    
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
                guard let posts = record[PostRecordKeyNames.posts.key] as? [String],
                    posts.contains(post.postID.recordName) else {
                        completion(error)
                        return
                }
                
                let updatedPosts = posts.filter{ $0 != post.postID.recordName }
                record[PostRecordKeyNames.posts.key] = updatedPosts as CKRecordValue?
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
    
    func delete(reaction: WanderReaction, completion: @escaping (Error?) -> Void ) {
        let deleteReaction = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [reaction.id])
        deleteReaction.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
            completion(error)
        }
        publicDatabase.add(deleteReaction)
    }    
}

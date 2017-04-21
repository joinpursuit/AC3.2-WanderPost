//
//  WanderPost.swift
//  Wandr
//
//  Created by C4Q on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import CloudKit


class WanderPost: ARAnnotation {
    let content: AnyObject
    let user: CKRecordID
    let contentType: PostContentType
    let privacyLevel: PrivacyLevel
    let reactionIDs: [CKRecordID]
    let postID: CKRecordID
    let time: Date
    let locationDescription: String
    var read: Bool
    let recipient: CKRecordID?
    
    var wanderUser: WanderUser?
    var reactions: [WanderReaction]?
    
    var dateAndTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    init (location: CLLocation,
          content: AnyObject,
          contentType: PostContentType,
          privacyLevel: PrivacyLevel,
          reactionIDs: [CKRecordID],
          postID: CKRecordID,
          time: Date,
          user: CKRecordID,
          locationDescription: String,
          read: Bool,
          recipient: CKRecordID?) {
        
        self.content = content
        self.contentType = contentType
        self.privacyLevel = privacyLevel
        self.reactionIDs = reactionIDs
        self.postID = postID
        self.time = time
        self.user = user
        self.locationDescription = locationDescription
        self.read = read
        self.recipient = recipient
        
        super.init()
            self.location = location
    }
    
    convenience init(location: CLLocation,
                     content: AnyObject,
                     contentType: PostContentType,
                     privacyLevel: PrivacyLevel,
                     locationDescription: String,
                     recipient: CKRecordID? = nil) {
        
        self.init(location: location,
                  content: content,
                  contentType: contentType,
                  privacyLevel: privacyLevel,
                  reactionIDs: [],
                  postID: CKRecordID(recordName: "foobar"),
                  time: Date(),
                  user: CloudManager.shared.currentUser!.id,
                  locationDescription: locationDescription,
                  read: false,
                  recipient: recipient)
    }
    
    convenience init?(withCKRecord record: CKRecord) {
        
        guard let content = record[PostRecordKeyNames.content.key],
            let location = record[PostRecordKeyNames.location.key] as? CLLocation,
            let user = record.creatorUserRecordID,
            let contentTypeString = record[PostRecordKeyNames.contentType.key] as? String,
            let contentType = PostContentType(rawValue: contentTypeString),
            let privacyLevelString = record[PostRecordKeyNames.privacyLevel.key] as? String,
            let privacyLevel = PrivacyLevel(rawValue: privacyLevelString),
            let time = record.creationDate,
            let locationDescription = record[PostRecordKeyNames.locationDescription.key] as? String,
            let read = record[PostRecordKeyNames.read.key] as? Bool
        else { return nil }
        
        let postID = record.recordID
        
        let reactionIDStrings = record[PostRecordKeyNames.reactions.key] as? [String] ?? []
        let reactionIDs = reactionIDStrings.asCloudKitRecordIDs
        
        let recipientID = record[PostRecordKeyNames.recipient.key] as? String
        let recipient: CKRecordID? = recipientID?.asCloudKitRecordID ?? nil
        
        self.init(location: location,
                  content: content as AnyObject,
                  contentType: contentType,
                  privacyLevel: privacyLevel,
                  reactionIDs: reactionIDs,
                  postID: postID,
                  time: time,
                  user: user,
                  locationDescription: locationDescription,
                  read: read,
                  recipient: recipient)
    }
}

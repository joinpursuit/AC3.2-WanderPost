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
        
        guard let content = record.object(forKey: PostRecordKeyNames.content.rawValue),
            let location = record.object(forKey: PostRecordKeyNames.location.rawValue) as? CLLocation,
            let user = record.creatorUserRecordID,
            let contentTypeString = record.object(forKey: PostRecordKeyNames.contentType.rawValue) as? NSString,
            let contentType = PostContentType(rawValue: contentTypeString),
            let privacyLevelString = record.object(forKey: PostRecordKeyNames.privacyLevel.rawValue) as? NSString,
            let privacyLevel = PrivacyLevel(rawValue: privacyLevelString),
            let time = record.creationDate,
            let locationDescription = record.object(forKey: PostRecordKeyNames.locationDescription.rawValue) as? String,
            let read = record.object(forKey: PostRecordKeyNames.read.rawValue) as? Bool
        else { return nil }
        
        let postID = record.recordID
        
        let reactionIDStrings = record.object(forKey: PostRecordKeyNames.reactions.rawValue) as? [String] ?? []
        let reactionIDs = reactionIDStrings.map { CKRecordID(recordName: $0) }
        
        var recipient: CKRecordID? = nil
        if let recipientID = record.object(forKey: PostRecordKeyNames.recipient.rawValue) as? String {
            recipient = CKRecordID(recordName: recipientID)
        }

        
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
    
    static func descriptionForPlaceMark(_ mark: CLPlacemark) -> String {
        var placeString = ""
        if let street = mark.thoroughfare {
            placeString += "\(street), "
        }
        if let boro = mark.subLocality {
            placeString += "\(boro), "
        }
        if let city = mark.locality {
            placeString += "\(city), "
        }
        if let zip = mark.postalCode {
            placeString += "\(zip)"
        }
        print(placeString)
        return placeString
    }

    
}

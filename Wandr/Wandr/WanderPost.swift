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
    let reactions: [Reaction]
    //Confirm that time is coming in as an (NS)Date
    let time: Date
    
    init (location: CLLocation, content: AnyObject, contentType: PostContentType, privacyLevel: PrivacyLevel, reactions: [Reaction], time: Date, user: CKRecordID) {
        self.content = content
        self.contentType = contentType
        self.privacyLevel = privacyLevel
        self.reactions = reactions
        self.time = time
        self.user = user
        
        super.init()
            self.location = location
        
    }
    
    convenience init(location: CLLocation, content: AnyObject, contentType: PostContentType, privacyLevel: PrivacyLevel) {
        self.init(location: location, content: content, contentType: contentType, privacyLevel: privacyLevel, reactions: [], time: Date(), user: CloudManager.shared.currentUser!)
    }
    
    convenience init?(withCKRecord record: CKRecord) {
        guard let content = record.object(forKey: "content"),
            let location = record.object(forKey: "location") as? CLLocation,
            let user = record.creatorUserRecordID,
            let contentTypeString = record.object(forKey: "contentType") as? NSString,
            let contentType = PostContentType(rawValue: contentTypeString),
            let privacyLevelString = record.object(forKey: "privacyLevel") as? NSString,
            let privacyLevel = PrivacyLevel(rawValue: privacyLevelString),
            let time = record.creationDate else { return nil }
        
        self.init(location: location, content: content as AnyObject, contentType: contentType, privacyLevel: privacyLevel, reactions: [], time: time, user: user)
    }
}

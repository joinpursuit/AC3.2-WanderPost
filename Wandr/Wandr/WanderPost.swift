//
//  WanderPost.swift
//  Wandr
//
//  Created by C4Q on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import CloudKit

class WanderPost {
    let location: CLLocation
    let content: AnyObject
    let user: CKRecordID? = CloudManager.shared.currentUser
    let contentType: PostContentType
    let privacyLevel: PrivacyLevel
    let reactions: [Reaction]
    //Confirm that time is coming in as an (NS)Date
    let time: Date
    
    init (location: CLLocation, content: AnyObject, contentType: PostContentType, privacyLevel: PrivacyLevel, reactions: [Reaction], time: Date) {
        self.location = location
        self.content = content
        self.contentType = contentType
        self.privacyLevel = privacyLevel
        self.reactions = reactions
        self.time = time
    }
}

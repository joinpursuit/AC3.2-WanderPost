//
//  Reaction.swift
//  Wandr
//
//  Created by C4Q on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

enum ReactionType: NSString {
    case like, comment
}

import Foundation
import CloudKit

class Reaction {
    let type: ReactionType
    let id: CKRecordID
    let time: Date
    let userID: CKRecordID
    let postID: CKReference
    let content: String
    
    init (type: ReactionType, id: CKRecordID, content: String, time: Date, userID: CKRecordID, postID: CKReference) {
        self.type = type
        self.content = content
        self.time = time
        self.userID = userID
        self.postID = postID
    }
    
    convenience init(type: ReactionType, content: String, postID: CKRecordID) {
        
        let userID = CloudManager.shared.currentUser!.id
        
        let postID = CKReference(recordID: postID, action: .deleteSelf)
        self.init(type: type,
                  id: CKRecordID(recordName: "foobar"),
                  content: content,
                  time: Date(),
                  userID: userID,
                  postID: postID)
    }
    
    convenience init?(from record: CKRecord) {
        
        guard let typeString = record["type"] as? NSString,
            let type = ReactionType(rawValue: typeString),
            let time = record.creationDate,
            let userID = record.creatorUserRecordID,
            let postID = record["postID"] as? CKReference,
            let content = record["content"] as? String else { return nil }
        let id = record.recordID

        self.init(type: type,
                  id: id,
                  content: content,
                  time: time,
                  userID: userID,
                  postID: postID)
    }
}

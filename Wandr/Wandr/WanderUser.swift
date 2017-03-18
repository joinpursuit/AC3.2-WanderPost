//
//  WanderUser.swift
//  Wandr
//
//  Created by C4Q on 3/8/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import CloudKit

class WanderUser {
    let id: CKRecordID
    let username: String
    let userImageData: Data
    let friends: [CKRecordID]
    let posts: [CKRecordID]
        
    init (id: CKRecordID, username: String, userImageData: Data, friends: [CKRecordID], posts: [CKRecordID]) {
        self.id = id
        self.username = username
        self.userImageData = userImageData
        self.friends = friends
        self.posts = posts
    }
    
    convenience init?(from record: CKRecord) {
        
        guard let username = record["username"] as? String,
            let userImageAsset = record["profileImage"] as? CKAsset,
            let userImageData = try? Data(contentsOf: userImageAsset.fileURL) else { return nil }
        
        let friendStrings = record["friends"] as? [String] ?? []
        let friends = friendStrings.map { CKRecordID(recordName: $0) }
        
        let postStrings = record["posts"] as? [String] ?? []
        let posts = postStrings.map { CKRecordID(recordName: $0) }
        
        let id = record.recordID
        
        self.init(id: id,
                  username: username,
                  userImageData: userImageData,
                  friends: friends,
                  posts: posts)
    }
}

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
    let friends: [String]
    let posts: [String]
    
    init (id: CKRecordID, username: String, userImageData: Data, friends: [String], posts: [String]) {
        self.id = id
        self.username = username
        self.userImageData = userImageData
        self.friends = friends
        self.posts = posts
    }
    
    convenience init?(from record: CKRecord) {
        guard let id = record.creatorUserRecordID,
            let username = record["username"] as? String,
            let userImageAsset = record["profileImage"] as? CKAsset,
            let userImageData = try? Data(contentsOf: userImageAsset.fileURL) else { return nil }
        let friends = record["friends"] as? [String] ?? []
        let posts = record["posts"] as? [String] ?? []
        
        self.init(id: id, username: username, userImageData: userImageData, friends: friends, posts: posts)
    }
}

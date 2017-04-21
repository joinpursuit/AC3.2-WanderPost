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
    var friends: [CKRecordID]
    let posts: [CKRecordID]
        
    init (id: CKRecordID, username: String, userImageData: Data, friends: [CKRecordID], posts: [CKRecordID]) {
        self.id = id
        self.username = username
        self.userImageData = userImageData
        self.friends = friends
        self.posts = posts
    }
    
    convenience init?(from record: CKRecord) {
        
        guard let username = record[UserRecordKeyNames.username.key] as? String,
            let userImageAsset = record[UserRecordKeyNames.profileImage.key] as? CKAsset,
            let userImageData = try? Data(contentsOf: userImageAsset.fileURL) else { return nil }
        
        let friendStrings = record[UserRecordKeyNames.friends.key] as? [String] ?? []
        let friends = friendStrings.asCloudKitRecordIDs
        
        let postStrings = record[UserRecordKeyNames.posts.key] as? [String] ?? []
        let posts = postStrings.asCloudKitRecordIDs
        
        let id = record.recordID
        
        self.init(id: id,
                  username: username,
                  userImageData: userImageData,
                  friends: friends,
                  posts: posts)
    }
}

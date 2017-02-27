//
//  Cloud Manager.swift
//  Wandr
//
//  Created by C4Q on 2/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//
import Foundation
import CloudKit

enum PostContentType {
    case audio, text, video
}

class CloudManager {
    static let shared = CloudManager()
    private init () {}
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    var currentUser: CKRecordID?
    
    func createPost (location: CLLocation, content: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        //Cast the content as valid types
        if currentUser == nil {
            getCurrentUser()
        }
        let postContent = content as NSString
        let userID = currentUser!.recordName as NSString
        
        //init set the information of the record
        let postRecord = CKRecord.init(recordType: "post")
        postRecord.setObject(location, forKey: "location")
        postRecord.setObject(postContent, forKey: "content")
        postRecord.setObject(userID, forKey: "userID")
        
        publicDatabase.save(postRecord) { (record, error) in
            
            switch error {
            case .some:
                completion(nil, error)
            case .none:
                completion(record, nil)
            }
        }
    }
    
    func createUser (userName: String, completion: @escaping (Error?) -> Void) {
        
        let validUsername = userName as NSString
        let id = CKRecordID(recordName: currentUser!.recordName)
        let userRecord = CKRecord(recordType: "user", recordID: id)
        
        userRecord.setObject(validUsername, forKey: "username")
        
        publicDatabase.save(userRecord) { (record, error) in
            completion(error)
        }
    }
 
    func getCurrentUser() {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                //Show an alert asking them to sign into iCloud?
            } else {
                print("fetched ID \(recordID?.recordName)")
                self.currentUser = recordID
            }
        }
    }

}

 

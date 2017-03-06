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
    let locationDescription: String
    var read: Bool
    
    var dateAndTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    init (location: CLLocation, content: AnyObject, contentType: PostContentType, privacyLevel: PrivacyLevel, reactions: [Reaction], time: Date, user: CKRecordID, locationDescription: String, read: Bool) {
        self.content = content
        self.contentType = contentType
        self.privacyLevel = privacyLevel
        self.reactions = reactions
        self.time = time
        self.user = user
        self.locationDescription = locationDescription
        self.read = read
        
        super.init()
            self.location = location
        
    }
    
    convenience init(location: CLLocation, content: AnyObject, contentType: PostContentType, privacyLevel: PrivacyLevel, locationDescription: String) {
        
        self.init(location: location, content: content, contentType: contentType, privacyLevel: privacyLevel, reactions: [], time: Date(), user: CloudManager.shared.currentUser!, locationDescription: locationDescription, read: false)
    }
    
    convenience init?(withCKRecord record: CKRecord) {
        guard let content = record.object(forKey: "content"),
            let location = record.object(forKey: "location") as? CLLocation,
            let user = record.creatorUserRecordID,
            let contentTypeString = record.object(forKey: "contentType") as? NSString,
            let contentType = PostContentType(rawValue: contentTypeString),
            let privacyLevelString = record.object(forKey: "privacyLevel") as? NSString,
            let privacyLevel = PrivacyLevel(rawValue: privacyLevelString),
            let time = record.creationDate,
            let locationDescription = record.object(forKey: "locationDescription") as? String,
            let read = record.object(forKey: "read") as? Bool
        else { return nil }
        
        
        self.init(location: location, content: content as AnyObject, contentType: contentType, privacyLevel: privacyLevel, reactions: [], time: time, user: user, locationDescription: locationDescription, read: read)
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

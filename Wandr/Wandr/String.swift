//
//  String.swift
//  Wandr
//
//  Created by C4Q on 4/21/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import CloudKit

extension String {
    var asCloudKitRecordID: CKRecordID {
        return CKRecordID(recordName: self)
    }
}

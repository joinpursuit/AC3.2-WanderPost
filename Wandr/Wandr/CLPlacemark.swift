//
//  CLPlacemark.swift
//  Wandr
//
//  Created by C4Q on 4/21/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import CloudKit

extension CLPlacemark {
    var readableDescription: String {
        var placeString = ""
        placeString += "\(self.thoroughfare ?? ""), "
        placeString += "\(self.subLocality ?? ""), "
        placeString += "\(self.locality ?? ""), "
        placeString += "\(self.postalCode ?? "")"
        return placeString
    }
}

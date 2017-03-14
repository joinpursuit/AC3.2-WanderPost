//
//  PostAnnotation.swift
//  Wandr
//
//  Created by Tom Seymour on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import MapKit

class PostAnnotation: MKPointAnnotation {
    
    var wanderpost: WanderPost!
    
    override init () {
        super.init()
    }
}

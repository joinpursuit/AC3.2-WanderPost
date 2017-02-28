//
//  Reaction.swift
//  Wandr
//
//  Created by C4Q on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

enum ReactionType {
    case like, comment
}

import Foundation

class Reaction {
    let type: ReactionType
    let content: String?
    
    init (type: ReactionType, content: String) {
        self.type = type
        self.content = content
    }
    
    //TODO Add a convience init to parse from the Cloud in a simple manner
}

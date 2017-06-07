//
//  WanderProfileImageView.swift
//  Wandr
//
//  Created by Ana Ma on 3/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

class WanderProfileImageView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    convenience init(width: CGFloat = 50.0, height: CGFloat = 50.0, borderWidth: CGFloat = 2.0) {
        self.init(image: #imageLiteral(resourceName: "default-placeholder"))
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = StyleManager.shared.accent.cgColor
        self.contentMode = .scaleAspectFill
        self.frame.size = CGSize(width: width, height: height)
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

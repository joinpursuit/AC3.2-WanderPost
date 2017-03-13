//
//  WanderButton.swift
//  Wandr
//
//  Created by Ana Ma on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

class WanderButton: UIButton {
    static let defaultSize = CGSize(width: 200, height: 40)
    convenience init(title: String, spacing: CGFloat = 16.0) {
        self.init()
        
        self.setTitle(title.lowercased(), for: .normal)
        self.backgroundColor = StyleManager.shared.primary
        self.titleLabel?.font = StyleManager.shared.comfortaaFont16
        self.setTitleColor(StyleManager.shared.accent, for: .normal)
        self.layer.borderColor = StyleManager.shared.secondaryText.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8.0
        
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: 0, bottom: insetAmount, right: insetAmount*1.5)
    }
    
    func setTextAndImageForButton(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: 0, bottom: insetAmount, right: insetAmount*1.5)
    }

}

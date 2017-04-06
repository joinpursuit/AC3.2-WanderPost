//
//  WanderTextField.swift
//  Wandr
//
//  Created by Ana Ma on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

//I don't think these should be in an extension, it makes more sense to me to have them as a part of the class of WanderTextField, are we using a UItextfield in a context that it's not a wandertextfield?

extension UITextField {
    
    func border(placeHolder: String = ""){
        //placeholder
        self.placeholder = placeHolder
        
        //color
        self.tintColor = StyleManager.shared.accent
        self.backgroundColor = UIColor.white
        
        //layer
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderColor = StyleManager.shared.primaryDark.cgColor
        self.layer.borderWidth = 1
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y:self.center.y))
        self.layer.add(animation, forKey: "position")
    }

}

class WanderTextField: UITextField {
     @IBInspectable var insetX: CGFloat = 8
     @IBInspectable var insetY: CGFloat = 4
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX , dy: insetY)
    }
}


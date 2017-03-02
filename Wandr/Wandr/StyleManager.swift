//
//  ColorManager.swift
//  Wandr
//
//  Created by Tom Seymour on 2/27/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class StyleManager {
    
    static let shared = StyleManager()
    private init() {}
    
    var primary: UIColor {
        return UIColor(hexString: "#4C669D")
    }
    var primaryDark: UIColor {
        return UIColor(hexString: "#283C68")
    }
    var primaryLight: UIColor {
        return UIColor(hexString: "#A9C5FF")
    }
    var accent: UIColor {
        return UIColor(hexString: "#B7F0A1")
    }
    var primaryText: UIColor {
        return UIColor(hexString: "#212121")
    }
    var secondaryText: UIColor {
        return UIColor(hexString: "#727272")
    }
    
    var comfortaaFont12: UIFont {
        return UIFont.Comfortaa.regular(size: 12)!
    }
    
    var comfortaaFont14: UIFont {
        return UIFont.Comfortaa.regular(size: 14)!
    }
    
    var comfortaaFont16: UIFont {
        return UIFont.Comfortaa.regular(size: 16)!
    }
    
    var comfortaaFont18: UIFont {
        return UIFont.Comfortaa.regular(size: 18)!
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIFont {
      
    struct Comfortaa {
        //MARK: - Methods
        static func light(size: CGFloat) -> UIFont? {
            return UIFont(name: "Comfortaa-Light", size: size)
        }
        
        static func regular(size: CGFloat) -> UIFont? {
            return UIFont(name: "Comfortaa", size: size)
        }
        
        static func bold(size: CGFloat) -> UIFont? {
            return UIFont(name: "Comfortaa-Bold", size: size)
        }
        
    }
}



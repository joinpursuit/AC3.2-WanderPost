//
//  ColorManager.swift
//  Wandr
//
//  Created by Tom Seymour on 2/27/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class ColorManager {
    
    static let shared = ColorManager()
    private init() {}
    
//    private let _50: UIColor = UIColor(hexString: "#E0F2F1")
//    private let _100: UIColor = UIColor(hexString: "#B2DFDB")
//    private let _200: UIColor = UIColor(hexString: "#80CBC4")
//    private let _300: UIColor = UIColor(hexString: "#4DB6AC")
//    private let _400: UIColor = UIColor(hexString: "#26A69A")
//    private let _500: UIColor = UIColor(hexString: "#009688")
//    private let _600: UIColor = UIColor(hexString: "#00897B")
//    private let _700: UIColor = UIColor(hexString: "#00796B")
//    private let _800: UIColor = UIColor(hexString: "#00695C")
//    private let _900: UIColor = UIColor(hexString: "#004D40")
//    private let a200: UIColor = UIColor(hexString: "#FFC400")
//    
//    var colorArray: [UIColor] {
//        return [_300, _400, _500, _600, _700, _800, _900, _800, _700, _600, _500, _400, _300, _200]
//    }
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


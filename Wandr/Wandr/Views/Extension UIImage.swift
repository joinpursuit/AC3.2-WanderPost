//
//  Extension UIImage.swift
//  Wandr
//
//  Created by Ana Ma on 3/10/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// UIImage extension to rotate images back to default orientation.
    /// http://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
    func fixRotatedImage() -> UIImage {
        switch self.imageOrientation {
        case UIImageOrientation.right:
            return UIImage(cgImage:self.cgImage!, scale: 1, orientation:UIImageOrientation.right);
        case UIImageOrientation.down:
            return UIImage(cgImage:self.cgImage!, scale: 1, orientation:UIImageOrientation.down);
        case UIImageOrientation.left:
            return UIImage(cgImage:self.cgImage!, scale: 1, orientation:UIImageOrientation.left);
        case UIImageOrientation.up:
            return self
        default:
            return UIImage(cgImage:self.cgImage!, scale: 1, orientation:UIImageOrientation.right);
        }
    }
}

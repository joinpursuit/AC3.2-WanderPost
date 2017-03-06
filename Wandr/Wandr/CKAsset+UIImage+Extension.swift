//
//  CKAsset+UIImage+Extension.swift
//  Wandr
//
//  Created by C4Q on 3/5/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

import UIKit
import CloudKit

enum ImageFileType {
    case JPG(compressionQuality: CGFloat)
    case PNG
    
    var fileExtension: String {
        switch self {
        case .JPG(_):
            return ".jpg"
        case .PNG:
            return ".png"
        }
    }
}

enum ImageError: Error {
    case UnableToConvertImageToData
}

extension CKAsset {
    convenience init(image: UIImage, fileType: ImageFileType = .JPG(compressionQuality: 70)) throws {
        let url = try image.saveToTempLocationWithFileType(fileType: fileType)
        self.init(fileURL: url as URL)
    }
    
    var image: UIImage? {
        guard let data = NSData(contentsOf: fileURL), let image = UIImage(data: data as Data) else { return nil }
        return image
    }
}

extension UIImage {
    func saveToTempLocationWithFileType(fileType: ImageFileType) throws -> NSURL {
        let imageData: NSData?
        
        switch fileType {
        case .JPG(let quality):
            imageData = UIImageJPEGRepresentation(self, quality) as NSData?
        case .PNG:
            imageData = UIImagePNGRepresentation(self) as NSData?
        }
        guard let data = imageData else {
            throw ImageError.UnableToConvertImageToData
        }
        
        let filename = ProcessInfo.processInfo.globallyUniqueString + fileType.fileExtension
        let url = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        try data.write(to: url, options: .atomicWrite)
        
        return url as NSURL
    }
}

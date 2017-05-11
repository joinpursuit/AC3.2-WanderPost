//
//  WandrTests.swift
//  WandrTests
//
//  Created by Ana Ma on 5/11/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import XCTest
import UIKit

class WandrTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func textImageRotation() {
        let image = #imageLiteral(resourceName: "logo_primary")
        let rotatedImageRight = UIImage(cgImage: image.cgImage!, scale: 1, orientation: UIImageOrientation.right)
        let rotatedImageDown = UIImage(cgImage: image.cgImage!, scale: 1, orientation: UIImageOrientation.down)
        let rotatedImageLeft = UIImage(cgImage: image.cgImage!, scale: 1, orientation: UIImageOrientation.left)
        let rotatedImageUp = UIImage(cgImage: image.cgImage!, scale: 1, orientation: UIImageOrientation.up)
        
        XCTAssert(image == rotatedImageRight.fixRotatedImage())
        XCTAssert(image == rotatedImageDown.fixRotatedImage())
        XCTAssert(image == rotatedImageLeft.fixRotatedImage())
        XCTAssert(image == rotatedImageUp.fixRotatedImage())
        

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


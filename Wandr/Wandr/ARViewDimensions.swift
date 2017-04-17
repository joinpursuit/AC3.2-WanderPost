//
//  ARViewDimensions.swift
//  Wandr
//
//  Created by Tom Seymour on 4/11/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

struct ARViewDimensions {
    
    // Basic ARView Dimensions
    
    private static let viewWidth: CGFloat = 120
    private static let viewMargin: CGFloat = 4
    private static let profileWidthHeight: CGFloat = ARViewDimensions.viewWidth / 3
    private static let viewHeight: CGFloat = ARViewDimensions.viewWidth + ARViewDimensions.profileWidthHeight + ARViewDimensions.viewMargin
    
    // Frames for ARView
    
    static let arViewFrame = CGRect(x: 0, y: 0, width: ARViewDimensions.viewWidth, height: ARViewDimensions.viewHeight)
    static let profileFrame = CGRect(x: (ARViewDimensions.viewWidth / 2) - (ARViewDimensions.profileWidthHeight / 2 ), y: 0, width: ARViewDimensions.profileWidthHeight, height: ARViewDimensions.profileWidthHeight)
    static let detailContainerFrame = CGRect(x: 0, y: ARViewDimensions.profileWidthHeight + ARViewDimensions.viewMargin, width: ARViewDimensions.viewWidth, height: ARViewDimensions.viewWidth)
    
    
    // Detail Container Frame Dimensions
    
    private static let contentWidth: CGFloat = ARViewDimensions.viewWidth - (2 * ARViewDimensions.viewMargin)
    private static let userHeight: CGFloat = ARViewDimensions.viewWidth / 4
    private static let timeDistanceHeight: CGFloat = ARViewDimensions.viewWidth / 6
    private static let messageHeight: CGFloat = ARViewDimensions.viewWidth - ARViewDimensions.userHeight - ARViewDimensions.timeDistanceHeight
    private static let distanceWidth: CGFloat = ARViewDimensions.contentWidth / 2.8
    private static let timeWidth: CGFloat = ARViewDimensions.contentWidth - ARViewDimensions.distanceWidth
    private static let timeDistanceYPos = ARViewDimensions.userHeight + ARViewDimensions.messageHeight
    private static let distanceXPos = ARViewDimensions.viewMargin + ARViewDimensions.timeWidth
    
    // Frames for ARView Detail Container
    
    static let userFrame = CGRect(x: ARViewDimensions.viewMargin, y: 0, width: ARViewDimensions.contentWidth, height: ARViewDimensions.userHeight)
    static let messageFrame = CGRect(x: ARViewDimensions.viewMargin, y: ARViewDimensions.userHeight, width: ARViewDimensions.contentWidth, height: ARViewDimensions.messageHeight)
    static let timeFrame = CGRect(x: ARViewDimensions.viewMargin, y: ARViewDimensions.timeDistanceYPos, width: ARViewDimensions.timeWidth, height: ARViewDimensions.timeDistanceHeight)
    static let distanceFrame = CGRect(x: ARViewDimensions.distanceXPos, y: ARViewDimensions.timeDistanceYPos, width: ARViewDimensions.distanceWidth, height: ARViewDimensions.timeDistanceHeight)

}

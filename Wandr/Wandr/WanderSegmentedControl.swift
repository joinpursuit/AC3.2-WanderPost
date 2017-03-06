//
//  WanderSegmentedControl.swift
//  Wandr
//
//  Created by Ana Ma on 3/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import TwicketSegmentedControl

class WanderSegmentedControl: TwicketSegmentedControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sliderBackgroundColor = StyleManager.shared.accent
        self.font = StyleManager.shared.comfortaaFont14
        self.segmentsBackgroundColor = StyleManager.shared.primary
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}

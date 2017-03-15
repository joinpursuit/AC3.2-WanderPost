//
//  Extension UIButton.swift
//  Wandr
//
//  Created by Ana Ma on 3/14/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func animate() {
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.transform = CGAffineTransform.identity
                        }
        })
    }
}

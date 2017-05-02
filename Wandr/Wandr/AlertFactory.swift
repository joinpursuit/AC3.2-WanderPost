//
//  AlertFactory.swift
//  Wandr
//
//  Created by C4Q on 5/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

struct AlertFactory {
    
    private let kDefaultTitle = "ERROR!"
    private let kDefaultMessage = "Something went wrong, please try again"
    private let view: UIViewController
    
    init(for view: UIViewController) {
        self.view = view
    }
    
    func makeDefaultOKAlert() {
        makeCustomOKAlert(title: kDefaultTitle, message: kDefaultMessage)
    }
    
    func makeCustomOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
            if let completionAction = completion {
                completionAction()
            }
        }
        alert.addAction(okayAction)
        view.present(alert, animated: true, completion: nil)
    }
}

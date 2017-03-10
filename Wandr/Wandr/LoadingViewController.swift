//
//  LoadingViewController.swift
//  Wandr
//
//  Created by C4Q on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        CloudManager.shared.getCurrentUser { (error) in
            //Error handling
            CloudManager.shared.addSubscriptionToCurrentuser { (error) in
                //Error handling
                DispatchQueue.main.async {
                    self.resetRootView()
                }
            }
        }
    }

    func resetRootView() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let rootVC = AppDelegate.setUpAppNavigation()
            appDelegate.setNavigationTheme()
            appDelegate.window?.rootViewController = rootVC
            //self.resetRootVC()
            self.dismiss(animated: true) {
                appDelegate.window?.makeKeyAndVisible()
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

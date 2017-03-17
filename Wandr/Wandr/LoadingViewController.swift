//
//  LoadingViewController.swift
//  Wandr
//
//  Created by C4Q on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit
import CloudKit

class LoadingViewController: UIViewController {
    
    var animator: UIViewPropertyAnimator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleManager.shared.primary
        setupViewHierarchy()
        configureConstraints()
        
        //TODO: This needs to present an alert if you aren't signed into iCloud
        
        CloudManager.shared.getCurrentUser { (validWanderUser, error) in
            //Error handling
            
            if error != nil {
                //TODO: Handle errors
               // self.showOKAlert(title: "Uh-oh...", message: error!.localizedDescription)
                
                if let ckError = error as? CKError {
                    print(ckError.errorUserInfo)
                }
                print(error)
            } else if validWanderUser {
                CloudManager.shared.addSubscriptionToCurrentUser { (error) in
                    //Error handling
                    CloudManager.shared.addSubscriptionForPersonalPosts { (error) in
                        DispatchQueue.main.async {
                            self.resetRootView()
                        }
                    }
                }
            } else {
                self.present(OnBoardViewController(), animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        flipLogoFromFourToTwoToRight()
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
    
    func flipLogoFromFourToTwoToRight() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromRight
        UIView.transition(with: self.logo1, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo1.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo2, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints { (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.bottom.equalToSuperview()
                view.top.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }) { (completion: Bool) in
            self.flipLogoFromTwoToOneToTop()
        }
    }
    
    func flipLogoFromTwoToOneToTop() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromBottom
        UIView.transition(with: self.logo2, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo3, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints { (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }) { (completion: Bool) in
            self.flipLogoFromOneToOne()
        }
    }
    
    func flipLogoFromOneToOne() { //
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromRight
        UIView.transition(with: self.logo1, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo1.snp.remakeConstraints({ (view) in
                view.leading.top.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo2, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints { (view) in
                view.leading.top.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo3, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints({ (view) in
                view.leading.top.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo4, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo4.snp.remakeConstraints { (view) in
                view.leading.top.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }){ (completion: Bool) in
            self.flipLogoFromTwoToOneToBottom()
        }
    }
    
    func flipLogoFromTwoToOneToBottom() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromTop
        UIView.transition(with: self.logo2, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints({ (view) in
                view.leading.bottom.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.top.equalTo(self.logoContainerView.snp.centerY)
            })
            
        }, completion: nil)
        UIView.transition(with: self.logo3, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints { (view) in
                view.leading.bottom.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.top.equalTo(self.logoContainerView.snp.centerY)
            }
            
        }) { (completion: Bool) in
            self.flipLogoFromTwoToFourToRight()
        }
    }
    
    func flipLogoFromTwoToFourToRight() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromRight
        UIView.transition(with: self.logo4, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo4.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            
        }, completion: nil)
        UIView.transition(with: self.logo3, duration: 0.5, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.bottom.equalToSuperview()
                view.top.equalTo(self.logoContainerView.snp.centerY)
            })
        }) { (completion: Bool) in
            self.flipLogoFromFourToTwoToRight()
        }
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(logoContainerView)
        self.logoContainerView.addSubview(logo1)
        self.logoContainerView.addSubview(logo2)
        self.logoContainerView.addSubview(logo3)
        self.logoContainerView.addSubview(logo4)
        self.view.addSubview(appNameLabel)
        self.view.addSubview(appTagLineLabel)
    }
    
    private func configureConstraints() {
        logo1.snp.removeConstraints()
        logo2.snp.removeConstraints()
        logo3.snp.removeConstraints()
        logo4.snp.removeConstraints()
        
        logoContainerView.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.centerX.equalToSuperview()
            view.height.equalTo(200)
            view.width.equalTo(200)
        }
        logo1.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview()
            view.trailing.equalTo(logoContainerView.snp.centerX)
            view.bottom.equalTo(logoContainerView.snp.centerY)
        }
        logo2.snp.makeConstraints { (view) in
            view.leading.bottom.equalToSuperview()
            view.trailing.equalTo(logoContainerView.snp.centerX)
            view.top.equalTo(logoContainerView.snp.centerY)
        }
        logo3.snp.makeConstraints { (view) in
            view.leading.equalTo(logoContainerView.snp.centerX)
            view.trailing.bottom.equalToSuperview()
            view.top.equalTo(logoContainerView.snp.centerY)
        }
        logo4.snp.makeConstraints { (view) in
            view.leading.equalTo(logoContainerView.snp.centerX)
            view.trailing.top.equalToSuperview()
            view.bottom.equalTo(logoContainerView.snp.centerY)
        }
        appNameLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.logoContainerView.snp.bottom).offset(16)
            label.centerX.equalToSuperview()
        }
        
        appTagLineLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.appNameLabel.snp.bottom).offset(16)
            label.centerX.equalToSuperview()
        }
    }
    
    //MARK: Views
    
    lazy var logoContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var logo1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "iconQuadrant")
        return imageView
    }()
    
    lazy var logo2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "iconQuadrant")
        return imageView
    }()
    
    lazy var logo3: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "iconQuadrant")
        return imageView
    }()
    
    lazy var logo4: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "iconQuadrant")
        return imageView
    }()
    
    //MARK: - Alert Helper Function
    
    lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.font = StyleManager.shared.comfortaaFont20
        label.textColor = UIColor.white
        label.text = "wanderpost"
        return label
    }()
    
    lazy var appTagLineLabel: UILabel = {
        let label = UILabel()
        label.font = StyleManager.shared.comfortaaFont16
        label.textColor = UIColor.white
        label.text = "Discover a world of hidden messages."
        return label
    }()

    func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
            if let completionAction = completion {
                completionAction()
            }
        }
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }

}

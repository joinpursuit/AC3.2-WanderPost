//
//  LoadingViewController.swift
//  Wandr
//
//  Created by C4Q on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class LoadingViewController: UIViewController {
    
    var animator: UIViewPropertyAnimator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleManager.shared.primary
        setupViewHierarchy()
        configureConstraints()
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
    
    override func viewDidAppear(_ animated: Bool) {
        //animateLogo()
        flipLogoFromFourToTwo()
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
    
    func flipLogoFromFourToTwo() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromRight
        UIView.transition(with: self.logo1, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo1.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo2, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints { (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.bottom.equalToSuperview()
                view.top.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }) { (completion: Bool) in
            self.flipLogoFromTwoToOne()
        }
    }
    
    func flipLogoFromTwoToOne() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromBottom
        UIView.transition(with: self.logo2, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo3, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints { (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.top.equalToSuperview()
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
            }){ (completion: Bool) in
                self.flipLogoFromOneToTwo()
        }
    }
    
    func flipLogoFromOneToTwo() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromTop
        UIView.transition(with: self.logo2, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints({ (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.bottom.equalToSuperview()
                view.top.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo3, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo3.snp.remakeConstraints { (view) in
                view.leading.equalTo(self.logoContainerView.snp.centerX)
                view.trailing.bottom.equalToSuperview()
                view.top.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }){ (completion: Bool) in
            self.flipLogoFromTwoToFour()
        }
    }
    
    func flipLogoFromTwoToFour() {
        let flipTransitionOptions = UIViewAnimationOptions.transitionFlipFromLeft
        UIView.transition(with: self.logo1, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo1.snp.remakeConstraints({ (view) in
                view.leading.top.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.bottom.equalTo(self.logoContainerView.snp.centerY)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.logo2, duration: 1.0, options: flipTransitionOptions, animations: {
            self.logo2.snp.remakeConstraints { (view) in
                view.leading.bottom.equalToSuperview()
                view.trailing.equalTo(self.logoContainerView.snp.centerX)
                view.top.equalTo(self.logoContainerView.snp.centerY)
            }
            self.view.layoutIfNeeded()
        }) { (completion: Bool) in
            self.flipLogoFromFourToTwo()
        }

    }
    
    func animateLogo() {
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            self.logo1.transform = CGAffineTransform(rotationAngle: 360)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(logoContainerView)
        self.logoContainerView.addSubview(logo1)
        self.logoContainerView.addSubview(logo2)
        self.logoContainerView.addSubview(logo3)
        self.logoContainerView.addSubview(logo4)
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


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  OnBoardViewController.swift
//  Wandr
//
//  Created by Ana Ma on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class OnBoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = StyleManager.shared.primaryLight

        // Do any additional setup after loading the view.
        self.profileImageView.accessibilityIdentifier = "profileImageView"
        self.userNameTextField.accessibilityIdentifier = "userNameTextField"
        self.registerButton.accessibilityIdentifier = "registerButton"
        self.logoImageView.accessibilityIdentifier = "logoImageView"
        self.introLabel.accessibilityIdentifier = "introLabel"
        setupViewHierarchy()
        configureConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(profileImageView)
        self.view.addSubview(userNameTextField)
        self.view.addSubview(registerButton)
        self.view.addSubview(logoImageView)
        self.view.addSubview(introLabel)
    }
    
    private func configureConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            view.centerX.equalToSuperview()
            view.height.equalTo(150)
            view.width.equalTo(150)
        }
        
        userNameTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(self.profileImageView.snp.bottom).offset(8)
            textField.height.equalTo(30)
            textField.leading.equalToSuperview().offset(16)
            textField.trailing.equalToSuperview().inset(16)
        }
        
        registerButton.snp.makeConstraints { (button) in
            button.top.equalTo(self.userNameTextField.snp.bottom).offset(8)
            button.centerX.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { (view) in
            view.top.equalTo(self.registerButton.snp.bottom).offset(8)
            view.centerX.equalToSuperview()
            view.height.equalTo(75)
            view.width.equalTo(75)
        }

        introLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.logoImageView.snp.bottom).offset(8)
            label.leading.equalToSuperview().offset(16)
            label.trailing.equalToSuperview().inset(16)
            //label.bottom.equalTo(self.bottomLayoutGuide.snp.top).inset(8)
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = StyleManager.shared.accent.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150.0, height: 150.0)
        //let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        //imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()
    
    lazy var userNameTextField: WanderTextField = {
       let textField = WanderTextField()
        textField.border(placeHolder: "username")
        return textField
    }()

    lazy var registerButton: WanderButton = {
        let button = WanderButton(title: "register")
        return button
    }()
    
    lazy var logoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "IconWhite")
        imageView.frame.size = CGSize(width: 75.0, height: 75.0)
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var introLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Wanderpost uses your apple \n account to store your posts. \n Please add a username and profile picture."
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

}

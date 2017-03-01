//
//  PostViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import CloudKit

class PostViewController: UIViewController, UITextFieldDelegate {

    let segmentTitles = ["Internal", "Private", "Public"]
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellow
        setupViewHierarchy()
        configureConstraints()
        configureTargets()
        
        textField.becomeFirstResponder()
        
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        self.segmentedControl.delegate = self
        
    }
    
    // MARK: - Actions
    func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func postButtonPressed(_ sender: UIButton) {
        //init post, this is going to be a rough sketch of doing it
        let post = WanderPost(location: self.location, content: self.textField.text as AnyObject, contentType: .text, privacyLevel: .everyone, reactions: [], time: Date())
        
        CloudManager.shared.createPost(post: post) { (record, error) in
            dump(record)
        }
        //self.dismiss(animated: true, completion: nil)
    }
    
    func imageTapped() {
        
    }
    
    // MARK: - Layout
    private func setupViewHierarchy() {
        self.view.addSubview(postContainerView)
        self.postContainerView.addSubview(profileImageView)
        self.postContainerView.addSubview(segmentedControl)
        self.postContainerView.addSubview(textField)
        self.postContainerView.addSubview(postButton)
        self.postContainerView.addSubview(dismissButton)
    }
    
    private func configureConstraints() {
        postContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { (button) in
            button.top.equalToSuperview().offset(16)
            button.leading.equalToSuperview().offset(16)
            button.height.equalTo(50.0)
            button.width.equalTo(50.0)
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16)
            view.trailing.equalToSuperview().inset(16)
            view.height.equalTo(50.0)
            view.width.equalTo(50.0)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.equalTo(profileImageView.snp.bottom).offset(8)
            control.leading.equalToSuperview().offset(8.0)
            control.trailing.equalToSuperview().inset(8.0)
            control.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { (textField) in
            textField.top.equalTo(segmentedControl.snp.bottom).offset(8)
            textField.leading.equalToSuperview().offset(16.0)
            textField.trailing.equalToSuperview().inset(16.0)
            textField.height.equalTo(150)
        }
        
        postButton.snp.makeConstraints { (button) in
            button.top.equalTo(textField.snp.bottom).offset(8)
            button.trailing.equalToSuperview().inset(16)
            button.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configureTargets () {
        postButton.addTarget(self, action: #selector(postButtonPressed(_:)), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed(_:)), for: .touchUpInside)
    }
    
    //MARK: - Views

    lazy var postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 50.0, height: 50.0)
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()

    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()
    
    lazy var textField: UITextField = {
       let textField = UITextField()
        textField.backgroundColor = UIColor.blue
        return textField
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton()
        button.setTitle("post", for: .normal)
        return button
    }()
    
    lazy var dismissButton: UIButton = {
       let button = UIButton()
        button.setTitle("X", for: .normal)
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        return button
    }()
    
}

extension PostViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            print("Internal")
        case 1:
            print("Private")
        case 2:
            print("Public")
        default:
            print("Can not make a decision")
        }
    }
}


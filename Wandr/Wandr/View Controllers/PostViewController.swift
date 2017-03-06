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
    
    let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    let privacyLevelArray = PrivacyLevelManager.shared.privacyLevelArray
    
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleManager.shared.primaryDark
        setupViewHierarchy()
        configureConstraints()
        configureTargets()
        
        textField.becomeFirstResponder()
        
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        
    }
    
    // MARK: - Actions
    func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func postButtonPressed(_ sender: UIButton) {
        //init post, this is going to be a rough sketch of doing it
        let content = self.textField.text as AnyObject
        let privacy = privacyLevelArray[segmentedControl.selectedSegmentIndex]
        
        self.dismiss(animated: true, completion: nil)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            if let error = error {
                print("error with geocoder: \(error)")
            }
            if let marks = placemarks, let thisMark = marks.last {
                let locationDescription = WanderPost.descriptionForPlaceMark(thisMark)
                let post = WanderPost(location: self.location, content: content, contentType: .text, privacyLevel: privacy, locationDescription: locationDescription)
                
                CloudManager.shared.createPost(post: post) { (record, errors) in
                    if errors != nil {
                        print(errors)
                        //TODO Add in error handling.
                    }
                    print("\n\ni think this works? \n\n")
                    //DO SOMETHING WITH THE RECORD?
                    dump(record)
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func imageTapped() {
        
    }
    
    // MARK: - Layout
    private func setupViewHierarchy() {
        self.view.addSubview(postContainerView)
        self.postContainerView.addSubview(profileImageView)
        self.postContainerView.addSubview(segmentedControlContainerView)
        self.postContainerView.addSubview(textField)
        self.postContainerView.addSubview(postButton)
        self.postContainerView.addSubview(dismissButton)
        
        self.segmentedControlContainerView.addSubview(segmentedControl)
    }
    
    private func configureConstraints() {
        postContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalToSuperview()
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
        
        segmentedControlContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(8)
            view.leading.equalToSuperview().offset(16.0)
            view.trailing.equalToSuperview().inset(16.0)
            view.height.equalTo(30)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.trailing.leading.bottom.equalToSuperview()
        }
        
        textField.snp.makeConstraints { (textField) in
            textField.top.equalTo(segmentedControlContainerView.snp.bottom).offset(16.0)
            textField.leading.equalToSuperview().offset(16.0)
            textField.trailing.equalToSuperview().inset(16.0)
            textField.height.equalTo(150)
        }
        
        postButton.snp.makeConstraints { (button) in
            button.top.equalTo(textField.snp.bottom).offset(8)
            button.trailing.equalToSuperview().inset(16)
        }
    }
    
    func configureTargets () {
        postButton.addTarget(self, action: #selector(postButtonPressed(_:)), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissButtonPressed(_:)), for: .touchUpInside)
    }
    
    //MARK: - Views
    
    lazy var postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleManager.shared.primaryLight
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = StyleManager.shared.accent.cgColor
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
    
    lazy var segmentedControlContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var segmentedControl: WanderSegmentedControl = {
        let control = WanderSegmentedControl()
        control.delegate = self
        return control
    }()
    
    lazy var textField: WanderTextField = {
        let textField = WanderTextField()
        //textField.tintColor = StyleManager.shared.accent
        //textField.backgroundColor = UIColor.white
        textField.border(placeHolder: "message")
        textField.font = StyleManager.shared.comfortaaFont18
        textField.textAlignment = NSTextAlignment.left
        return textField
    }()
    
    lazy var postButton: WanderButton = {
        let button = WanderButton(title: "post")
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.tintColor = StyleManager.shared.primaryDark
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


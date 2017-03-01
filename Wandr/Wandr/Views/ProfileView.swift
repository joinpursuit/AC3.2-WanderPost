//
//  ProfileView.swift
//  Wandr
//
//  Created by Ana Ma on 3/1/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit
import TwicketSegmentedControl

class ProfileView: UIView {
    override func draw(_ rect: CGRect) {
        // Drawing code
        setupViewHierarchy()
        configureConstraints()
    }
    
    private func setupViewHierarchy() {
        self.addSubview(profileImageView)
        self.addSubview(userNameLabel)
        self.addSubview(postNumberLabel)
        self.addSubview(followersNumberLabel)
        self.addSubview(followingNumberLabel)
    }
    
    private func configureConstraints() {
        // Subviews of profileContainerView
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(8)
            view.centerX.equalToSuperview()
            view.height.equalTo(150)
            view.width.equalTo(150)
        }
        
        userNameLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.profileImageView.snp.bottom).offset(8)
            label.centerX.equalToSuperview()
            label.height.equalTo(30)
        }
        
        followersNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview()
            label.height.equalTo(30)
        }
        
        postNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.trailing.equalTo(self.followersNumberLabel.snp.leading).offset(-16.0)
            label.height.equalTo(30)
        }
        
        
        followingNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.leading.equalTo(self.followersNumberLabel.snp.trailing).offset(16.0)
            label.height.equalTo(30)
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.blue.cgColor
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
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name"
        return label
    }()
    
    lazy var postNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Posts"
        return label
    }()
    
    lazy var followersNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Followers"
        return label
    }()
    
    lazy var followingNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Following"
        return label
    }()
}

class SegmentedControlHeaderFooterView: UITableViewHeaderFooterView {
    static let identifier = "segmentedControlHeaderFooterViewIdentifier"
    
    let segmentTitles = ["Internal", "Private", "Public"]
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        setupViewHierarchy()
        configureConstraints()
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
    }
    
    private func setupViewHierarchy() {
        self.addSubview(segmentedControl)
    }
    
    private func configureConstraints() {
        segmentedControl.snp.makeConstraints { (control) in
            control.top.leading.trailing.bottom.equalToSuperview()
            control.height.equalTo(40.0)
        }
    }
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()

}

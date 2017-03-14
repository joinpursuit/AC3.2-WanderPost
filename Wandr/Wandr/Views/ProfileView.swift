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

protocol ProfileViewDelegate {
    func imageViewTapped()
}

class ProfileView: UIView {
    override func draw(_ rect: CGRect) {
        // Drawing code
        setupViewHierarchy()
        configureConstraints()
    }
    
    var delegate : ProfileViewDelegate?
    
    private func setupViewHierarchy() {
        self.addSubview(profileImageView)
        self.addSubview(userNameLabel)
        self.addSubview(postNumberLabel)
        self.addSubview(friendsNumberLabel)
    }
    
    private func configureConstraints() {
        // Subviews of profileContainerView
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(16)
            view.centerX.equalToSuperview()
            view.height.equalTo(150)
            view.width.equalTo(150)
        }
        
        userNameLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.profileImageView.snp.bottom).offset(8)
            label.centerX.equalToSuperview()
            label.height.equalTo(30)
        }
        
        postNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview().offset(-self.frame.width / 6)
            label.height.equalTo(30)
        }
        
        friendsNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview().offset(self.frame.width / 6)
            label.height.equalTo(30)
        }
    }
    
    // Mark:- Action 
    func imageViewTapped() {
        self.delegate?.imageViewTapped()
        //print("ImageViewTapped")
    }
    
    lazy var profileImageView: WanderProfileImageView = {
        let imageView = WanderProfileImageView(width: 150.0, height: 150.0, borderWidth: 3.0)
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = StyleManager.shared.comfortaaFont20
        label.textColor = StyleManager.shared.primaryDark
        return label
    }()
    
    lazy var postNumberLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = StyleManager.shared.comfortaaFont14
        label.textColor = StyleManager.shared.primaryDark
        return label
    }()
    
    lazy var friendsNumberLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.font = StyleManager.shared.comfortaaFont14
        label.textColor = StyleManager.shared.primaryDark
        label.textAlignment = .center
        return label
    }()
    
    lazy var followersNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Followers"
        label.font = StyleManager.shared.comfortaaFont14
        return label
    }()
    
    lazy var followingNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Following"
        label.font = StyleManager.shared.comfortaaFont14
        return label
    }()
    
}

class SegmentedControlHeaderFooterView: UITableViewHeaderFooterView {
    static let identifier = "segmentedControlHeaderFooterViewIdentifier"
    
    let segmentTitles = [ProfileViewFilterType.posts.rawValue, ProfileViewFilterType.feed.rawValue, ProfileViewFilterType.messages.rawValue]
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        setupViewHierarchy()
        configureConstraints()
        //let frame = CGRect(x: 5, y: 5, width: self.frame.width - 10, height: 40)
        //self.segmentedControl = TwicketSegmentedControl(frame: frame)
        self.contentView.backgroundColor = StyleManager.shared.primaryLight
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
    }
    
    private func setupViewHierarchy() {
        self.addSubview(segmentedControl)
    }
    
    private func configureConstraints() {
        segmentedControl.snp.makeConstraints { (control) in
            control.top.equalToSuperview()
            control.leading.equalToSuperview().offset(22)
            control.trailing.equalToSuperview().inset(22)
            control.bottom.equalToSuperview()
            control.height.equalTo(44.0)
        }
    }
    
    lazy var segmentedControl: WanderSegmentedControl = {
        let control = WanderSegmentedControl()
        return control
    }()

}

//
//  ProfileViewViewControllerDetailFeedTableViewCell.swift
//  Wandr
//
//  Created by Ana Ma on 3/6/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class ProfileViewViewControllerDetailFeedTableViewCell: UITableViewCell {
    static let identifier = "profileViewControllerDetailFeedTableViewCellIdentifier"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewHierarchy()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(Coder:) had not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupViewHierarchy() {
        self.addSubview(profileImageView)
        self.addSubview(nameLabel)
        self.addSubview(dateAndTimeLabel)
        self.addSubview(locationLabel)
        self.addSubview(messageLabel)
    }
    
    private func configureConstraints() {
        profileImageView.snp.makeConstraints{ (view) in
            view.top.equalToSuperview().offset(16.0)
            view.leading.equalToSuperview().offset(16.0)
            view.height.equalTo(50)
            view.width.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { (label) in
            label.top.equalToSuperview().offset(16.0)
            label.leading.equalTo(self.profileImageView.snp.trailing).offset(16.0)
            label.trailing.equalTo(self.dateAndTimeLabel.snp.leading)
            label.height.equalTo(30)
        }
        
        dateAndTimeLabel.snp.makeConstraints { (label) in
            label.top.equalToSuperview().offset(8.0)
            label.trailing.equalToSuperview().inset(8.0)
            label.height.equalTo(30)
        }
        
        locationLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.dateAndTimeLabel.snp.bottom).offset(4.0)
            label.trailing.equalToSuperview().inset(8.0)
            label.height.equalTo(30)
        }
        
        messageLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.dateAndTimeLabel.snp.bottom).offset(8.0)
            label.leading.equalTo(self.nameLabel.snp.leading)
            label.trailing.bottom.equalToSuperview().inset(8.0)
        }
    }
    
    lazy var profileImageView: WanderProfileImageView = {
        let imageView = WanderProfileImageView(width: 50.0, height: 50.0)
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = StyleManager.shared.comfortaaFont14
        label.tintColor = StyleManager.shared.secondaryText
        return label
    }()
    
    lazy var dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date & Time"
        label.font = StyleManager.shared.comfortaaFont14
        label.tintColor = StyleManager.shared.secondaryText
        return label
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = StyleManager.shared.comfortaaFont14
        label.tintColor = StyleManager.shared.secondaryText
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Message"
        label.font = StyleManager.shared.comfortaaFont14
        label.tintColor = StyleManager.shared.secondaryText
        label.numberOfLines = 0
        return label
    }()
    
}

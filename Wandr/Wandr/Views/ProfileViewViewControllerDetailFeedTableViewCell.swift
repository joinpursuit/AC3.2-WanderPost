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
    private let kTopBottomMarginNarrow = 11.0
    private let kTopBottomMargin = 16.0
    private let kTopBottomMarginWide = 22.0
    private let kLeadingTrailingMargin = 16.0
    private let kLeadingTrailingMarginWide = 22.0
    private let kProfileImageViewSide = 50.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = StyleManager.shared.primaryLight
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
        self.addSubview(messageLabel)
    }
    
    private func configureConstraints() {
        profileImageView.snp.makeConstraints{ (view) in
            view.top.equalToSuperview().offset(kTopBottomMargin)
            view.leading.equalToSuperview().offset(kLeadingTrailingMarginWide)
            view.height.equalTo(kProfileImageViewSide)
            view.width.equalTo(kProfileImageViewSide)
        }
        
        nameLabel.snp.makeConstraints { (label) in
            label.top.equalToSuperview().offset(kTopBottomMargin)
            label.leading.equalTo(self.profileImageView.snp.trailing).offset(kLeadingTrailingMarginWide)
        }
        
        dateAndTimeLabel.snp.makeConstraints { (label) in
            label.bottom.equalTo(nameLabel.snp.bottom)
            label.trailing.equalToSuperview().inset(kLeadingTrailingMargin)
            
        }
        
        messageLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.nameLabel.snp.bottom).offset(kTopBottomMarginNarrow)
            label.leading.equalTo(self.nameLabel.snp.leading)
            label.trailing.equalToSuperview().inset(kLeadingTrailingMargin)
            label.bottom.equalToSuperview().inset(kTopBottomMarginWide)
        }
    }
    
    lazy var profileImageView: WanderProfileImageView = {
        let imageView = WanderProfileImageView(width: self.kProfileImageViewSide, height: self.kProfileImageViewSide)
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = StyleManager.shared.comfortaaFont18
        label.textColor = StyleManager.shared.primaryDark
        return label
    }()
    
    lazy var dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = StyleManager.shared.comfortaaFont14
        label.textColor = StyleManager.shared.primaryDark
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = StyleManager.shared.comfortaaFont16
        label.tintColor = StyleManager.shared.primaryText
        label.numberOfLines = 0
        return label
    }()
    
}

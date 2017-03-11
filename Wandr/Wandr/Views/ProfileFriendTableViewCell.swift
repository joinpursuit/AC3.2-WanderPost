//
//  ProfileFriendTableViewCell.swift
//  Wandr
//
//  Created by Tom Seymour on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class ProfileFriendTableViewCell: UITableViewCell {

    static let identifier = "profileFriendTableViewCellIdentifier"
    
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
    
    func setupViewHierarchy() {
        self.addSubview(profileImageView)
        self.addSubview(nameLabel)
        self.addSubview(addRemoveFriendButton)
    }
    
    func configureConstraints() {
        profileImageView.snp.makeConstraints{ (view) in
            view.top.leading.equalToSuperview().offset(8.0)
            view.height.equalTo(50)
            view.width.equalTo(50)
            view.bottom.equalToSuperview().inset(8.0)
        }
        
        nameLabel.snp.makeConstraints { (label) in
            label.leading.equalTo(self.profileImageView.snp.trailing).offset(16.0)
            label.centerY.equalTo(self.profileImageView.snp.centerY)
            label.height.equalTo(30)
        }
        
        addRemoveFriendButton.snp.makeConstraints { (button) in
            button.leading.equalTo(self.nameLabel.snp.trailing).offset(8.0)
            button.centerY.equalTo(self.profileImageView.snp.centerY)
            button.trailing.equalToSuperview().inset(8.0)
        }
    }
    
    
    
    //MARK: - Lazy Vars
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = StyleManager.shared.comfortaaFont14
        label.tintColor = StyleManager.shared.secondaryText
        return label
    }()
    
    lazy var profileImageView: WanderProfileImageView = {
        let imageView = WanderProfileImageView(width: 50.0, height: 50.0)
        return imageView
    }()
    
    lazy var addRemoveFriendButton: WanderButton = {
       let button = WanderButton(title: "Add")
        return button
    }()


}

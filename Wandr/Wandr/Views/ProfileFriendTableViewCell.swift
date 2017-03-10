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
    }
    
    func configureConstraints() {
        profileImageView.snp.makeConstraints{ (view) in
            view.top.equalToSuperview().offset(16.0)
            view.leading.equalToSuperview().offset(16.0)
            view.height.equalTo(50)
            view.width.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { (label) in
            label.leading.equalTo(self.profileImageView.snp.trailing).offset(16.0)
            label.trailing.equalToSuperview().offset(-16)
            label.centerY.equalTo(self.profileImageView)
            label.height.equalTo(30)
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


}

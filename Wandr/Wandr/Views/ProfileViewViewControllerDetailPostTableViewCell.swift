//
//  ProfileViewViewControllerDetailPostTableViewCell.swift
//  Wandr
//
//  Created by Ana Ma on 3/1/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewViewControllerDetailPostTableViewCell: UITableViewCell {

    static let identifier = "profileViewControllerDetailPostTableViewCellIdentifier"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.locationLabel.accessibilityIdentifier = "locationLabel"
        self.dateAndTimeLabel.accessibilityIdentifier = "dateAndTimeLabel"
        self.messageLabel.accessibilityIdentifier = "messageLabel"
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
        self.addSubview(locationLabel)
        self.addSubview(dateAndTimeLabel)
        self.addSubview(messageLabel)
        self.addSubview(commentCountLabel)
    }
    
    private func configureConstraints() {
        locationLabel.snp.makeConstraints { (label) in
            label.top.leading.equalToSuperview().offset(16.0)
            label.trailing.equalToSuperview().inset(8.0)
        }
        
        dateAndTimeLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.locationLabel.snp.bottom).offset(8.0)
            label.leading.equalToSuperview().offset(16.0)
            label.trailing.equalToSuperview().inset(16.0)
        }
        
        messageLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.dateAndTimeLabel.snp.bottom).offset(16.0)
            label.leading.equalToSuperview().offset(16.0)
            label.trailing.equalToSuperview().inset(16.0)
            label.bottom.equalTo(self.commentCountLabel.snp.top).inset(8.0)
        }
        
        commentCountLabel.snp.makeConstraints { (label) in
            label.leading.equalToSuperview().offset(16.0)
            label.trailing.equalToSuperview().inset(16.0)
            label.bottom.equalToSuperview().inset(16.0)
        }
    }
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = StyleManager.shared.comfortaaFont16
        label.textColor = StyleManager.shared.primary
        return label
    }()

    lazy var dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date & Time"
        label.font = StyleManager.shared.comfortaaFont14
        label.textColor = StyleManager.shared.primary
        return label
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Message"
        label.font = StyleManager.shared.comfortaaFont14
        label.textColor = StyleManager.shared.primaryText
        label.numberOfLines = 0
        return label
    }()

    lazy var commentCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Comments #"
        label.textColor = StyleManager.shared.accent
        label.font = StyleManager.shared.comfortaaFont14
        label.textAlignment = .right
        return label
    }()
}

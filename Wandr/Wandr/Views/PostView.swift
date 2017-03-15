//
//  PostView.swift
//  Wandr
//
//  Created by Ana Ma on 3/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

class PostView: UIView {
    static let identifier = "postHeaderFooterViewIdentifier"
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.locationLabel.accessibilityIdentifier = "locationLabel"
        self.dateAndTimeLabel.accessibilityIdentifier = "dateAndTimeLabel"
        self.messageLabel.accessibilityIdentifier = "messageLabel"
        setupViewHierarchy()
        configureConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupViewHierarchy() {
        self.addSubview(locationLabel)
        self.addSubview(dateAndTimeLabel)
        self.addSubview(messageLabel)
        self.addSubview(commentCountLabel)
    }
    
    private func configureConstraints() {
        locationLabel.snp.makeConstraints { (label) in
            label.top.leading.equalToSuperview().offset(11.0)
            label.trailing.equalToSuperview().inset(11.0)
        }
        
        dateAndTimeLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.locationLabel.snp.bottom).offset(11.0)
            label.leading.equalToSuperview().offset(11.0)
            label.trailing.equalToSuperview().inset(11.0)
        }
        
        messageLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.dateAndTimeLabel.snp.bottom).offset(11.0)
            label.leading.equalToSuperview().offset(11.0)
            label.trailing.equalToSuperview().inset(11.0)
            label.bottom.equalTo(self.commentCountLabel.snp.top).inset(11.0)
        }
        
        commentCountLabel.snp.makeConstraints { (label) in
            label.leading.equalToSuperview().offset(11.0)
            label.trailing.equalToSuperview().inset(11.0)
            label.bottom.equalToSuperview().inset(11.0)
        }
    }
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = StyleManager.shared.comfortaaFont16
        label.textColor = StyleManager.shared.primary
        label.numberOfLines = 0
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
        label.font = UIFont.systemFont(ofSize: 16)
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

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
        self.addSubview(nameLabel)
        self.addSubview(dateAndTimeLabel)
        self.addSubview(locationLabel)
        self.addSubview(messageLabel)
    }
    
    private func configureConstraints() {
        
    }
    
    lazy var nameLabel: UILabel = {
       let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    lazy var dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date & Time"
        return label
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        return label
    }()

    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Message"
        label.numberOfLines = 0
        return label
    }()

}

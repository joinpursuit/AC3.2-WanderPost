//
//  CommentsSectionHeaderView.swift
//  Wandr
//
//  Created by Tom Seymour on 3/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class CommentsSectionHeaderView: UITableViewHeaderFooterView {

    static let identifier = "commentsSectionHeaderViewIdentifier"
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        setupViewHierarchy()
        configureConstraints()
        self.backgroundColor = StyleManager.shared.primaryLight
    
    }
    
    private func setupViewHierarchy() {
        self.addSubview(sectionNameLabel)
    }
    
    private func configureConstraints() {
        sectionNameLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.leading.equalToSuperview()
            view.trailing.equalToSuperview()
        }
    }
    
    lazy var sectionNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = StyleManager.shared.sectionHeaderGray
        label.text = "    comments"
        label.textColor = StyleManager.shared.primaryDark
        label.font = StyleManager.shared.comfortaaFont18
        return label
    }()

}



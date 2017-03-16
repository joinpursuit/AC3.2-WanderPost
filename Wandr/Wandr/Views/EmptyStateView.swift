//
//  EmptyStateView.swift
//  Wandr
//
//  Created by Tom Seymour on 3/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class EmptyStateView: UIView {

    var textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.backgroundColor = .clear
        view.textColor = StyleManager.shared.primaryDark
        view.font = StyleManager.shared.comfortaaFont18
        view.textAlignment = .center
        view.text = "..."
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = StyleManager.shared.primaryDark
        view.hidesWhenStopped = true
        return view
    }()
    
    let view = UIView()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.view.backgroundColor = StyleManager.shared.primaryLight
        self.addSubview(view)
        self.addSubview(textLabel)
        self.addSubview(activityIndicator)
        view.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        textLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.leading.equalToSuperview().offset(11)
            view.trailing.equalToSuperview().inset(11)
        }
        activityIndicator.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
        }
    }
    
    func loading() {
        self.textLabel.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.textLabel.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    
    

}

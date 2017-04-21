//
//  WanderMapAnnotationView.swift
//  Wandr
//
//  Created by Tom Seymour on 3/3/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

class WanderMapAnnotationView: MKAnnotationView {

    let profileImageHeightMultiplyer: CGFloat = 1.85
    let profileImagViewBorderWidth: CGFloat = 1.5
    let profileImageViewCenterOffset: CGFloat = -10
    
    var profileImageViewHeight: CGFloat!
    let annotationImage = UIImage(named: "wanderPin4")!
    
    var profileImageView: UIImageView = UIImageView()
    var animateDrop = false
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = annotationImage
        profileImageViewHeight = frame.height / profileImageHeightMultiplyer
        setupView()
        setConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(profileImageView)
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = profileImageViewHeight / 2
        self.profileImageView.layer.borderWidth = profileImagViewBorderWidth
        self.profileImageView.layer.borderColor = StyleManager.shared.accent.cgColor
    }
    
    func setConstraints() {
        self.profileImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.centerY.equalToSuperview().offset(profileImageViewCenterOffset)
            view.width.height.equalTo(profileImageViewHeight)
        }
    }
}

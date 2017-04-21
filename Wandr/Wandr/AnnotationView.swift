//
//  AnnotationView.swift
//  Wandr
//
//  Created by Tom Seymour on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

//1
protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

//2
class AnnotationView: ARAnnotationView {
    //3
    
    private let arViewBorderWidth: CGFloat = 2
    private let detailContainerBackgroundColor = UIColor(white: 0.3, alpha: 0.6)
    
    private var profileImageView: UIImageView!
    private var detailContainerView: UIView!
    private var userLabel: UILabel!
    private var messageLabel: UILabel!
    private var timeLabel: UILabel!
    private var distanceLabel: UILabel!
    
    private let profileFrame = ARViewDimensions.profileFrame
    private let detailContainerFrame = ARViewDimensions.detailContainerFrame
    private let userFrame = ARViewDimensions.userFrame
    private let messageFrame = ARViewDimensions.messageFrame
    private let timeFrame = ARViewDimensions.timeFrame
    private let distanceFrame = ARViewDimensions.distanceFrame
    
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.backgroundColor = .clear
        setUpViews()
        configureViews()
        loadUI()
    }
    
    func setUpViews() {
        profileImageView?.removeFromSuperview()
        userLabel?.removeFromSuperview()
        messageLabel?.removeFromSuperview()
        timeLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        detailContainerView?.removeFromSuperview()
        
        profileImageView = UIImageView(frame: profileFrame)
        detailContainerView = UIView(frame: detailContainerFrame)
        userLabel = UILabel(frame: userFrame)
        messageLabel = UILabel(frame: messageFrame)
        timeLabel = UILabel(frame: timeFrame)
        distanceLabel = UILabel(frame: distanceFrame)
    }
    
    func configureViews() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileFrame.width / 2
        profileImageView.layer.borderWidth = arViewBorderWidth
        profileImageView.layer.borderColor = StyleManager.shared.accent.cgColor
        
        detailContainerView.backgroundColor = detailContainerBackgroundColor
        detailContainerView.clipsToBounds = true
        detailContainerView.layer.cornerRadius = detailContainerFrame.width / 12
        detailContainerView.layer.borderWidth = arViewBorderWidth
        detailContainerView.layer.borderColor = StyleManager.shared.primary.cgColor
        
        userLabel.font = StyleManager.shared.comfortaaFont14
        userLabel.numberOfLines = 1
        userLabel.textColor = StyleManager.shared.accent
        userLabel.textAlignment = .center
        
        messageLabel.font = StyleManager.shared.system12
        messageLabel.numberOfLines = 0
        messageLabel.textColor = UIColor.white
        messageLabel.clipsToBounds = true
        
        timeLabel.font = StyleManager.shared.system8
        timeLabel.numberOfLines = 1
        timeLabel.textColor = UIColor.white
        
        distanceLabel.font = StyleManager.shared.system8
        distanceLabel.numberOfLines = 1
        distanceLabel.textColor = StyleManager.shared.accent
        
        self.addSubview(detailContainerView)
        self.addSubview(profileImageView)
        detailContainerView.addSubview(timeLabel)
        detailContainerView.addSubview(messageLabel)
        detailContainerView.addSubview(userLabel)
        detailContainerView.addSubview(distanceLabel)
    }
    
    //4
    func loadUI() {
        if let wanderPostForThisAnnotation = annotation as? WanderPost,
            let user = wanderPostForThisAnnotation.wanderUser {
            profileImageView.image = UIImage(data: user.userImageData)
            userLabel.text = user.username
            messageLabel.text = wanderPostForThisAnnotation.content as? String
            distanceLabel.text = String(format: "%.2f km", wanderPostForThisAnnotation.distanceFromUser / 1000)
            timeLabel.text = wanderPostForThisAnnotation.dateAndTime
        }
    }
    
    //1
      override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView?.frame = profileFrame
        userLabel?.frame = userFrame
        messageLabel?.frame = messageFrame
        timeLabel?.frame = timeFrame
        distanceLabel?.frame = distanceFrame
    }
    
    //2
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
}

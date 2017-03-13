//
//  AnnotationView.swift
//  Places
//
//  Created by Tom Seymour on 3/1/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

//1
protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

//2
class AnnotationView: ARAnnotationView {
    //3
    
    var profileImageView: UIImageView?
    
    var detailContainerView: UIView?
    var userLabel: UILabel?
    var messageLabel: UILabel?
    var timeLabel: UILabel?
    var distanceLabel: UILabel?
    
//    private let viewBackgroundColor: UIColor = UIColor(white: 0.3, alpha: 0.7)
    
    private let profileFrame = CGRect(x: 40, y: 0, width: 40, height: 40)
    private let detailContainerFrame = CGRect(x: 0, y: 44, width: 120, height: 120)
    private let userFrame = CGRect(x: 4, y: 0, width: 112, height: 30)
    private let messageFrame = CGRect(x: 4, y: 30, width: 112, height: 70)
    private let timeFrame = CGRect(x: 4, y: 100, width: 72, height: 20)
    private let distanceFrame = CGRect(x: 76, y: 100, width: 40, height: 20)
    
    
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.backgroundColor = .clear
//        self.clipsToBounds = true
//        self.layer.cornerRadius = 10
        setUpViews()
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
    
    //4
    func loadUI() {
        
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.cornerRadius = 20
        self.addSubview(profileImageView!)
        
        detailContainerView?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        detailContainerView?.clipsToBounds = true
        detailContainerView?.layer.cornerRadius = 10
        self.addSubview(detailContainerView!)
        
        userLabel?.font = StyleManager.shared.comfortaaFont14
        userLabel?.numberOfLines = 1
        userLabel?.textColor = StyleManager.shared.primaryDark
        userLabel?.textAlignment = .center
//        self.addSubview(userLabel!)
        detailContainerView?.addSubview(userLabel!)
        
        messageLabel?.font = UIFont.systemFont(ofSize: 12)
        messageLabel?.numberOfLines = 0
        messageLabel?.textColor = UIColor.white
        messageLabel?.clipsToBounds = true
//        self.addSubview(messageLabel!)
        detailContainerView?.addSubview(messageLabel!)
        
        timeLabel?.font = UIFont.systemFont(ofSize: 8)
        timeLabel?.numberOfLines = 1
        timeLabel?.textColor = UIColor.white
//        self.addSubview(timeLabel!)
        detailContainerView?.addSubview(timeLabel!)
        
        
        distanceLabel?.font = UIFont.systemFont(ofSize: 8)
        distanceLabel?.numberOfLines = 1
        distanceLabel?.textColor = StyleManager.shared.accent
//        self.addSubview(distanceLabel!)
        detailContainerView?.addSubview(distanceLabel!)
        
        if let wanderPostForThisAnnotation = annotation as? WanderPost {
            if let user = wanderPostForThisAnnotation.wanderUser {
                profileImageView?.image = UIImage(data: user.userImageData)
                userLabel?.text = user.username
            }
            messageLabel?.text = wanderPostForThisAnnotation.content as? String
            distanceLabel?.text = String(format: "%.2f km", wanderPostForThisAnnotation.distanceFromUser / 1000)
            timeLabel?.text = wanderPostForThisAnnotation.dateAndTime
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

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
    var userLabel: UILabel?
    var messageLabel: UILabel?
    var timeLabel: UILabel?
    var distanceLabel: UILabel?
    
    private let viewBackgroundColor: UIColor = UIColor(white: 0.3, alpha: 0.7)
    
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.backgroundColor = viewBackgroundColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        setUpViews()
        loadUI()
    }
    
    func setUpViews() {
        profileImageView?.removeFromSuperview()
        userLabel?.removeFromSuperview()
        messageLabel?.removeFromSuperview()
        timeLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        
        profileImageView = UIImageView(frame: CGRect(x: 8, y: 0, width: 30, height: 30))
        
        userLabel = UILabel(frame: CGRect(x: 46, y: 0, width: self.frame.size.width - 16 - 38, height: 30))
        messageLabel = UILabel(frame: CGRect(x: 8, y: 30, width: self.frame.size.width - 16, height: 150))
        
        timeLabel = UILabel(frame: CGRect(x: 8, y: 180, width: 130 - 16, height: 20))
        distanceLabel = UILabel(frame: CGRect(x: 108, y: 180, width: 70 - 16, height: 20))
    }
    
    //4
    func loadUI() {
        
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.cornerRadius = 15
        self.addSubview(profileImageView!)
        
        userLabel?.font = StyleManager.shared.comfortaaFont14
        userLabel?.numberOfLines = 1
        userLabel?.textColor = StyleManager.shared.primaryDark
        self.addSubview(userLabel!)
        
        messageLabel?.font = UIFont.systemFont(ofSize: 12)
        messageLabel?.numberOfLines = 0
        messageLabel?.textColor = UIColor.white
        messageLabel?.clipsToBounds = true
        self.addSubview(messageLabel!)
        
        timeLabel?.font = UIFont.systemFont(ofSize: 10)
        timeLabel?.numberOfLines = 1
        timeLabel?.textColor = UIColor.white
        self.addSubview(timeLabel!)
        
        
        distanceLabel?.font = UIFont.systemFont(ofSize: 10)
        distanceLabel?.numberOfLines = 1
        distanceLabel?.textColor = StyleManager.shared.accent
        self.addSubview(distanceLabel!)
        
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
        profileImageView?.frame = CGRect(x: 8, y: 0, width: 30, height: 30)
        userLabel?.frame = CGRect(x: 46, y: 0, width: self.frame.size.width - 16 - 38, height: 30)
        messageLabel?.frame = CGRect(x: 8, y: 30, width: self.frame.size.width - 16, height: 150)
        timeLabel?.frame = CGRect(x: 8, y: 180, width: 130 - 16, height: 20)
        distanceLabel?.frame = CGRect(x: 108, y: 180, width: 70 - 16, height: 20)
    }
    
    //2
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
}

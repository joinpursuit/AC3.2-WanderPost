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
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var timeLabel: UILabel?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    //4
    func loadUI() {
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        timeLabel?.removeFromSuperview()
        
        let title = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 50))
        title.font = UIFont.systemFont(ofSize: 16)
        title.numberOfLines = 0
        title.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        title.textColor = UIColor.white
        
        self.addSubview(title)
        self.titleLabel = title
        
        let time = UILabel(frame: CGRect(x: 10, y: 50, width: self.frame.size.width, height: 20))
        time.font = UIFont.systemFont(ofSize: 16)
        time.numberOfLines = 1
        time.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        time.textColor = UIColor.white
        
        self.addSubview(time)
        self.timeLabel = time
        
        distanceLabel = UILabel(frame: CGRect(x: 10, y: 70, width: self.frame.size.width, height: 20))
        distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = StyleManager.shared.accent
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(distanceLabel!)
        
        if let annotation = annotation as? WanderPost {
            print("................\nSuccess")
            dump(annotation.location)
            titleLabel?.text = annotation.content as! String
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
            timeLabel?.text = annotation.dateAndTime
        }
    }
    
    //1
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20)
    }
    
    //2
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
    
}

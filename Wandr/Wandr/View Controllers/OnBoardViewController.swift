//
//  OnBoardViewController.swift
//  Wandr
//
//  Created by Ana Ma on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit

class OnBoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewHierarchy() {
        
    }
    
    private func configureConstraints() {
        
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = StyleManager.shared.accent.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150.0, height: 150.0)
        //let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        //imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()
    
    lazy var userNameTextField: UITextField = {
       let textField = UITextField()
        return textField
    }()


}

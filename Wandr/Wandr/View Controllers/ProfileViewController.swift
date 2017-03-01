//
//  ProfileViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import SnapKit
import TwicketSegmentedControl

class ProfileViewController: UIViewController {

    let segmentTitles = ["Internal", "Private", "Public"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "wanderpost"
        
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        setupViewHierarchy()
        configureConstraints()
        
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        self.segmentedControl.delegate = self
        
        //profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(profileContainerView)
        self.profileContainerView.addSubview(profileImageView)
        self.profileContainerView.addSubview(userNameLabel)
        self.profileContainerView.addSubview(postNumberLabel)
        self.profileContainerView.addSubview(followersNumberLabel)
        self.profileContainerView.addSubview(segmentedControl)
        
        self.view.addSubview(postTableView)
        
    }
    
    private func configureConstraints() {
        // Subviews of view
        profileContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
            //view.height.equalTo(self.view.snp.height).multipliedBy(0.6)
        }
        
        postTableView.snp.makeConstraints { (view) in
            view.top.equalTo(self.profileContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            view.height.equalTo(self.view.snp.height).multipliedBy(0.3)
        }
        
        // Subviews of profileContainerView
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(8)
            view.centerX.equalToSuperview()
            //view.height.equalToSuperview().multipliedBy(0.8)
            //view.width.equalTo(view.height as! ConstraintRelatableTarget)
            view.height.equalTo(150)
            view.width.equalTo(150)
        }
        
        userNameLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.profileImageView.snp.bottom).offset(8)
            label.centerX.equalToSuperview()
            label.height.equalTo(30)
        }
        
        postNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview().inset( -(self.view.frame.width / 4))
            label.height.equalTo(30)
        }
        
        followersNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview().inset(self.view.frame.width / 4)
            label.height.equalTo(30)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.equalTo(self.followersNumberLabel.snp.bottom).offset(8)
            control.bottom.equalToSuperview()
            control.leading.trailing.equalToSuperview()
            control.height.equalTo(40)
        }
        
    }


    // MARK: - Actions
    func imageTapped() {
        //Able to change profile picture
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Views
    
    lazy var profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "default-placeholder")
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.blue.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 150.0, height: 150.0)
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name"
        return label
    }()
    
    lazy var postNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Posts"
        return label
    }()
    
    lazy var followersNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Followers"
        return label
    }()
    
    lazy var FollowingNumberLaber: UILabel = {
        let label = UILabel()
        label.text = "#Following"
        return label
    }()
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()
    
    lazy var postTableView: UITableView = {
       let tableView = UITableView()
        return tableView
    }()

}

extension ProfileViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            print("Internal")
        case 1:
            print("Private")
        case 2:
            print("Public")
        default:
            print("Can not make a decision")
        }
    }
}

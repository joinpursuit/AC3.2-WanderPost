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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let segmentTitles = ["Internal", "Private", "Public"]

    let dummyData = ["name": "Ana", "date": "3-1-17", "time": "3:00PM", "location": "Quuens", "message": "There's a nice view outside"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white

        setupViewHierarchy()
        configureConstraints()
        
        //SegmentedControl
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        self.segmentedControl.delegate = self
        
        //TabelViewCell
        self.postTableView.register(ProfileViewViewControllerDetailPostTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier)
    }
    
    // MARK: - Actions
    func imageTapped() {
        //Able to change profile picture
    }
    
    func togglePostTableView() {
        
    }
    //Table header
    //Section header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return segmentedControlContainerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200.0
    }
    
    
    // MARK: - TableViewDelegate and TableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailPostTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    private func setupViewHierarchy() {
        self.view.addSubview(profileContainerView)
        self.profileContainerView.addSubview(profileImageView)
        self.profileContainerView.addSubview(userNameLabel)
        self.profileContainerView.addSubview(postNumberLabel)
        self.profileContainerView.addSubview(followersNumberLabel)
        self.profileContainerView.addSubview(followingNumberLabel)
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
        
        followersNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.centerX.equalToSuperview()
            label.height.equalTo(30)
        }
        
        postNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.trailing.equalTo(self.followersNumberLabel.snp.leading).offset(-16.0)
            label.height.equalTo(30)
        }
        
        
        followingNumberLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.userNameLabel.snp.bottom).offset(8)
            label.leading.equalTo(self.followersNumberLabel.snp.trailing).offset(16.0)
            label.height.equalTo(30)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.equalTo(self.followersNumberLabel.snp.bottom).offset(8)
            control.bottom.equalToSuperview()
            control.leading.trailing.equalToSuperview()
            control.height.equalTo(40)
        }
    }
    
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
    
    lazy var followingNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "#Following"
        return label
    }()
    
    lazy var segmentedControlContainerView = {
        let view = UIView()
        return view
    }()
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()
    
    lazy var postTableView: UITableView = {
       let tableView = UITableView()
        tableView.delegate = self
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePostTableView))
        swipeUpGesture.direction = .up
        tableView.addGestureRecognizer(swipeUpGesture)
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

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
import AVKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ProfileViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    
    let dummyData = ["name": "Ana", "date": "3-1-17", "time": "3:00PM", "location": "Quuens", "message": "There's a nice view outside"]
    
    let dummyData2 = [1,2,3,4,5,6,7,8,9,10,11,12,13]
    
    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white

        setupViewHierarchy()
        configureConstraints()
        
        //TabelViewCell
        self.postTableView.register(ProfileViewViewControllerDetailPostTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier)
        
        //TableViewHeader
        self.postTableView.register(SegmentedControlHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SegmentedControlHeaderFooterView.identifier)
        
        //TableViewSectionHeader
        let profileViewFrame = CGRect(x: 0, y: 0, width: postTableView.frame.size.width, height: 275.0)
        self.profileHeaderView = ProfileView(frame: profileViewFrame)
        self.profileHeaderView.backgroundColor = StyleManager.shared.primaryLight
        postTableView.tableHeaderView = self.profileHeaderView
        self.profileHeaderView.delegate = self
    }
    
    // MARK: - Actions
    func imageViewTapped() {
        //Able to change profile picture
        print("self.profileHeaderView.profileImageView")
        self.showImagePickerForSourceType(sourceType: .photoLibrary)
    }
    
    // MARK: - PhotoPicker Methods
    private func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
        self.imagePickerController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.profileHeaderView.profileImageView.image = image
        }
        dump(info)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Header And Footer Customizations
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let segmentedControl = self.postTableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentedControlHeaderFooterView.identifier) as? SegmentedControlHeaderFooterView
        segmentedControl?.segmentedControl.delegate = self
        
        return segmentedControl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    // MARK: - TableViewDelegate and TableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummyData2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailPostTableViewCell
        cell.nameLabel.text = "\(self.dummyData2[indexPath.row])"
        //cell.nameLabel.text = self.dummyData["name"]
        //cell.dateAndTimeLabel.text = "\(self.dummyData["date"]) \(self.dummyData["time"])"
        //cell.locationLabel.text = self.dummyData["location"]
        //cell.messageLabel.text = self.dummyData["message"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Layout
    private func setupViewHierarchy() {
        self.view.addSubview(postTableView)
    }
    
    private func configureConstraints() {
        postTableView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
    }
    
    //MARK: - Views
    lazy var profileHeaderView: ProfileView = {
        let view = ProfileView()
        return view
    }()
    
    lazy var postTableView: UITableView = {
       let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = 100
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

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
    
    let dummyDataFeed = [1,2,3,4,5,6,7,8,9,10,11,12,13]
    let dummyDataMessage = [1,2,3,4,5]
    
    var wanderUser: WanderUser!
    var wanderPosts: [WanderPost]?
    
    var profileViewFilterType: ProfileViewFilterType = ProfileViewFilterType.posts
    
    var imagePickerController: UIImagePickerController!
    
    var segmentedControlCurrentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white
        
        let searchFriendsButton = UIBarButtonItem(image: UIImage(named: "search"), style: .done, target: self, action: #selector(friendsButtonTapped))
        self.navigationItem.rightBarButtonItem = searchFriendsButton
        
        setupViewHierarchy()
        configureConstraints()
        
        guard let validWanderUser = CloudManager.shared.currentUser else { return }
        self.wanderUser = validWanderUser
        
        //TabelViewCell
        self.postTableView.register(ProfileViewViewControllerDetailPostTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier)
        self.postTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)
        
        //TableViewHeader
        self.postTableView.register(SegmentedControlHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SegmentedControlHeaderFooterView.identifier)
        
        //TableViewSectionHeader
        let profileViewFrame = CGRect(x: 0, y: 0, width: postTableView.frame.size.width, height: 275.0)
        self.profileHeaderView = ProfileView(frame: profileViewFrame)
        self.profileHeaderView.backgroundColor = StyleManager.shared.primaryLight
        guard let validOriginalImage = UIImage(data: CloudManager.shared.currentUser!.userImageData) else { return }
        //Do not delete becase imageToDisplay will be the long term solution
        let imageToDisplay = validOriginalImage.fixRotatedImage()
        let tempRotateSolution = UIImage(cgImage: validOriginalImage.cgImage!, scale: validOriginalImage.scale, orientation: UIImageOrientation.right)
        self.profileHeaderView.profileImageView.image = tempRotateSolution
        self.profileHeaderView.userNameLabel.text = self.wanderUser.username
        postTableView.tableHeaderView = self.profileHeaderView
        self.profileHeaderView.delegate = self
        
        CloudManager.shared.getUserPostActivity(for: self.wanderUser.id) { (wanderPosts:[WanderPost]?, error: Error?) in
            if error != nil {
                print(error?.localizedDescription)
            }
            
            guard let validWanderPosts = wanderPosts else { return }
            self.wanderPosts = validWanderPosts
            self.wanderPosts = validWanderPosts.sorted(by: {$0.0.time > $0.1.time} )
            self.profileHeaderView.postNumberLabel.text = "\(validWanderPosts.count) \n posts"
            self.profileHeaderView.friendsNumberLabel.text = "\(self.wanderUser.friends.count) \n friends"
            
            
            CloudManager.shared.getInfo(forPosts: validWanderPosts, completion: { (error) in
                print(error)
                
                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                }
            })
        }
        
    }
    
    // MARK: - Actions
    func imageViewTapped() {
        //Able to change profile picture
        print("self.profileHeaderView.profileImageView")
        self.showImagePickerForSourceType(sourceType: .photoLibrary)
    }
    
    func friendsButtonTapped() {
        let friendsVC = ProfileFriendsTableViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(friendsVC, animated: true)
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
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageToDisplay = originalImage.fixRotatedImage()
            self.profileHeaderView.profileImageView.image = imageToDisplay
        }
        dump(info)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Header And Footer Customizations
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let segmentedControlHeaderFooterView = (self.postTableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentedControlHeaderFooterView.identifier) as? SegmentedControlHeaderFooterView)!
        self.segmentedControl = segmentedControlHeaderFooterView.segmentedControl
        self.segmentedControl.delegate = self
        
        return segmentedControlHeaderFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    // MARK: - TableViewDelegate and TableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.profileViewFilterType {
        case ProfileViewFilterType.posts:
            guard let posts = self.wanderPosts else { return 0 }
            return posts.count
        case ProfileViewFilterType.feed:
            return self.dummyDataFeed.count
        case ProfileViewFilterType.messages:
            return self.dummyDataMessage.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.profileViewFilterType{
        case ProfileViewFilterType.posts:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailPostTableViewCell
            guard let post = self.wanderPosts?[indexPath.row] else { return cell }
            cell.locationLabel.text = post.locationDescription
            cell.messageLabel.text = post.content as? String
            cell.dateAndTimeLabel.text = post.dateAndTime
            
            let reactionsCount = post.reactions?.count ?? 0
            if reactionsCount < 2 {
                cell.commentCountLabel.text = "\(reactionsCount) Comment"
            } else {
                cell.commentCountLabel.text = "\(reactionsCount) Comments"
            }
        
            return cell
            
        case ProfileViewFilterType.feed:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
            cell.locationLabel.text = "Location: \(self.dummyDataFeed[indexPath.row])"
            return cell
            
        case ProfileViewFilterType.messages:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailPostTableViewCell
            cell.locationLabel.text = "Location: \(self.dummyDataMessage[indexPath.row])"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.profileViewFilterType{
        case ProfileViewFilterType.posts:
            
            guard let selectedWanderPost = self.wanderPosts?[indexPath.row] else { return }
            let detailPostViewWithCommentsViewController = DetailPostViewWithCommentsViewController()
            detailPostViewWithCommentsViewController.wanderPost = selectedWanderPost
            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationController?.pushViewController(detailPostViewWithCommentsViewController, animated: true)
            
        case ProfileViewFilterType.feed:
            print(ProfileViewFilterType.feed.rawValue)
        case ProfileViewFilterType.messages:
            print(ProfileViewFilterType.messages.rawValue)
        }
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
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let segmentedControl = TwicketSegmentedControl()
        return segmentedControl
    }()
    
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.right
        tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        return tableView
    }()
    
    func updateSegmentedControl(gesture: UISwipeGestureRecognizer) {
        print("I've been Swiped!")
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            let newIndex = segmentedControlCurrentIndex + 1
            if newIndex < self.segmentTitles.count {
                self.segmentedControlCurrentIndex = (self.segmentedControlCurrentIndex + 1) % self.segmentTitles.count
                self.segmentedControl.move(to: self.segmentedControlCurrentIndex)
                didSelect(self.segmentedControlCurrentIndex)
                self.postTableView.reloadData()
            }
        case UISwipeGestureRecognizerDirection.left:
            let newIndex = segmentedControlCurrentIndex - 1
            if newIndex >= 0 {
                self.segmentedControlCurrentIndex = (self.segmentedControlCurrentIndex - 1) % self.segmentTitles.count
                if self.segmentedControlCurrentIndex < 0 {
                    self.segmentedControlCurrentIndex += 3
                }                
                self.segmentedControl.move(to: self.segmentedControlCurrentIndex)
                didSelect(self.segmentedControlCurrentIndex)
                self.postTableView.reloadData()
            }
        default:
            break
        }
    }
}


extension ProfileViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            self.profileViewFilterType = ProfileViewFilterType.posts
        case 1:
            self.profileViewFilterType = ProfileViewFilterType.feed
        case 2:
            self.profileViewFilterType = ProfileViewFilterType.messages
        default:
            print("Can not make a decision")
        }
        self.postTableView.reloadData()
    }
    
}

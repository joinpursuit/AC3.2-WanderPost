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
import CloudKit

class ProfileViewController: UIViewController {
    
    fileprivate let segmentTitles = PrivacyLevel.orderedStrings()
    
    fileprivate var friendFeedPosts = [WanderPost]()
    fileprivate var friendFeedLoading: Bool = true
    
    fileprivate var personalPosts = [WanderPost]()
    fileprivate var personalPostsLoading: Bool = true
    
    fileprivate var wanderUser: WanderUser!
    fileprivate var wanderPosts: [WanderPost]?
    
    fileprivate var userFriends: [WanderUser]?
    
    fileprivate var profileViewFilterType: ProfileViewFilterType = ProfileViewFilterType.feed
    
    fileprivate var imagePickerController: UIImagePickerController!
    
    fileprivate var segmentedControlCurrentIndex = 0
    
    fileprivate let feedCellSeparatorInsets = UIEdgeInsets(top: 0, left: 94, bottom: 0, right: 16)
    fileprivate let postCellSeparatorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    fileprivate let heightForSectionHeader: CGFloat = 38
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white
        
        let searchFriendsButton = UIBarButtonItem(image: UIImage(named: "search"), style: .done, target: self, action: #selector(searchButtonTapped))
        self.navigationItem.rightBarButtonItem = searchFriendsButton
        
        guard let validWanderUser = CloudManager.shared.currentUser else { return }
        wanderUser = validWanderUser
        
        setupTableView()
        setupViewHierarchy()
        configureConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wanderUser = CloudManager.shared.currentUser!
        setUpUserHistory()
        setUpFriendsFeed()
        getUserFriends()
        setUpPrivateMessages()
        self.postTableView.reloadData()
    }
    
    // MARK: - Actions
    func searchButtonTapped() {
        goToFriendsVC(displayType: .searchedFriends)
    }
    
    func goToFriendsVC(displayType: FriendSearchDisplayType) {
        let friendsVC = ProfileFriendsTableViewController()
        friendsVC.friendDisplayType = displayType
        friendsVC.userFriends = userFriends
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    
    // MARK: - PhotoPicker Methods
    fileprivate func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
        self.imagePickerController = imagePickerController
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - TableView Cell, Header and Section Customizations
    func setupTableView() {
        //TabelViewCell
        self.postTableView.register(ProfileViewViewControllerDetailPostTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier)
        self.postTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)
        
        //TableViewHeader
        self.postTableView.register(SegmentedControlHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SegmentedControlHeaderFooterView.identifier)
        
        //TableViewSectionHeader
        let profileViewFrame = CGRect(x: 0, y: 0, width: postTableView.frame.size.width, height: 260.0)
        self.profileHeaderView = ProfileView(frame: profileViewFrame)
        self.profileHeaderView.backgroundColor = StyleManager.shared.primaryLight
        guard let validOriginalImage = UIImage(data: CloudManager.shared.currentUser!.userImageData) else { return }
        let imageToDisplay = validOriginalImage.fixRotatedImage()
        self.profileHeaderView.profileImageView.image = imageToDisplay
        self.profileHeaderView.userNameLabel.text = self.wanderUser.username
        postTableView.tableHeaderView = self.profileHeaderView
        self.profileHeaderView.delegate = self
    }
    
    // MARK: - Helper Functions
    func toggleNoPostsLabel(posts: [WanderPost], loading: Bool) {
        if loading {
            noPostsLabel.loading()
            noPostsLabel.isHidden = false
            postTableView.isScrollEnabled = false
            return
        } else {
            noPostsLabel.stopLoading()
        }
        
        if posts.isEmpty {
            noPostsLabel.isHidden = false
            postTableView.isScrollEnabled = false
        } else {
            noPostsLabel.isHidden = true
            postTableView.isScrollEnabled = true
        }
    }
    
    // MARK: - Layout
    private func setupViewHierarchy() {
        self.view.addSubview(postTableView)
        self.view.addSubview(noPostsLabel)
    }
    
    private func configureConstraints() {
        self.edgesForExtendedLayout = []
        postTableView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        noPostsLabel.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            let height = self.view.frame.height - (self.profileHeaderView.frame.height + ((self.tabBarController?.tabBar.frame.height)! + (self.navigationController?.navigationBar.frame.height)! * 2) + self.heightForSectionHeader)
            view.height.equalTo(height)
        }
    }
    
    //MARK: - Views
    var profileHeaderView = ProfileView()
    var segmentedControl = TwicketSegmentedControl()
    
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.right
        tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        return tableView
    }()
    
    lazy var noPostsLabel: EmptyStateView = {
        let view = EmptyStateView()
        view.textLabel.text = "no posts to display\n"
        view.isHidden = true
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(updateSegmentedControl(gesture:)))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(leftSwipeGestureRecognizer)
        return view
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
    
    //CloudManager Methods
    func setUpPrivateMessages () {
        personalPostsLoading = true
        CloudManager.shared.findPrivateMessages(for: self.wanderUser) { (privateMessages, error) in
            if error != nil {
                AlertFactory.init(for: self).makeDefaultOKAlert()
            }
            
            if let validPrivateMessages = privateMessages {
                
                CloudManager.shared.getInfo(forPosts: validPrivateMessages, completion: { (error) in
                    
                    if error != nil {
                        AlertFactory.init(for: self).makeDefaultOKAlert()
                    }
                    
                    DispatchQueue.main.async {
                        self.personalPosts = validPrivateMessages.sorted(by: {$0.0.time > $0.1.time} )
                        self.personalPostsLoading = false
                        self.postTableView.reloadData()
                    }
                })
            }
        }
    }
    
    func setUpUserHistory() {
        CloudManager.shared.getUserPostActivity(for: self.wanderUser.id) { (wanderPosts:[WanderPost]?, error: Error?) in
            if error != nil {
                AlertFactory.init(for: self).makeDefaultOKAlert()
            }
            
            guard let validWanderPosts = wanderPosts else { return }
            self.wanderPosts = validWanderPosts.sorted(by: {$0.0.time > $0.1.time} )
            DispatchQueue.main.async {
                self.profileHeaderView.postNumberLabel.text = "\(validWanderPosts.count) \n posts"
                self.profileHeaderView.friendsNumberLabel.text = "\(self.wanderUser.friends.count) \n friends"                
            }
            
            CloudManager.shared.getInfo(forPosts: validWanderPosts, completion: { (error) in
                
                if error != nil {
                    AlertFactory.init(for: self).makeDefaultOKAlert()
                }

                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                }
            })
        }
    }
    
    func setUpFriendsFeed() {
        friendFeedLoading = wanderUser.friends.isEmpty ? false : true
        friendFeedPosts = []
        
        for friend in wanderUser.friends {
            CloudManager.shared.getUserPostActivity(for: friend) { (wanderPosts:[WanderPost]?, error: Error?) in
                if error != nil {
                    AlertFactory.init(for: self).makeDefaultOKAlert()
                }
                
                guard let validWanderPosts = wanderPosts else {
                    DispatchQueue.main.async {
                        self.friendFeedLoading = false
                        self.postTableView.reloadData()
                    }
                    return
                }
                
                self.friendFeedPosts += validWanderPosts.filter { $0.privacyLevel != .personal }
                self.friendFeedPosts.sort(by: {$0.0.time > $0.1.time} )
                
                CloudManager.shared.getInfo(forPosts: validWanderPosts, completion: { (error) in
                    if error != nil {
                        AlertFactory.init(for: self).makeDefaultOKAlert()
                    }
                    DispatchQueue.main.async {
                        self.friendFeedLoading = false
                        self.postTableView.reloadData()
                    }
                })
            }
        }
    }
    
    func getUserFriends() {
        CloudManager.shared.getInfo(forUsers: CloudManager.shared.currentUser!.friends) { (userFriends: [WanderUser]?, error: Error?) in
            if error != nil {
                AlertFactory.init(for: self).makeDefaultOKAlert()
            }
            if let friends = userFriends {
                DispatchQueue.main.async {
                    self.userFriends = friends
                }
            }
        }
    }
}

// MARK: - ProfileViewDelegate Method
extension ProfileViewController: ProfileViewDelegate {
    func imageViewTapped() {
        //Able to change profile picture
        print("self.profileHeaderView.profileImageView")
        self.showImagePickerForSourceType(sourceType: .photoLibrary)
    }
    
    func postsLabelTapped() {
        segmentedControlCurrentIndex = 1
        segmentedControl.move(to: segmentedControlCurrentIndex)
        self.didSelect(segmentedControlCurrentIndex)
        postTableView.reloadData()
    }
    
    func friendsLabelTapped() {
        goToFriendsVC(displayType: .userFriends)
    }
}

// MARK: - RemovePostDelegate Method 
extension ProfileViewController: RemovePostDelegate {
    func deletePost(post: WanderPost) {
        wanderPosts! = wanderPosts!.filter { $0.postID != post.postID }
        postTableView.reloadData()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageToDisplay = originalImage.fixRotatedImage()
            self.profileHeaderView.profileImageView.image = imageToDisplay
        }
        dump(info)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            self.profileViewFilterType = ProfileViewFilterType.feed
            self.postTableView.separatorInset = feedCellSeparatorInsets
        case 1:
            self.profileViewFilterType = ProfileViewFilterType.posts
            self.postTableView.separatorInset = postCellSeparatorInsets
        case 2:
            self.profileViewFilterType = ProfileViewFilterType.personal
            self.postTableView.separatorInset = postCellSeparatorInsets

        default:
            print("Can not make a decision")
        }
        self.postTableView.reloadData()
    }
    
}

// MARK: - TableViewDataSource Methods
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.profileViewFilterType {
        case ProfileViewFilterType.posts:
            guard let posts = self.wanderPosts else { return 0 }
            
            toggleNoPostsLabel(posts: posts, loading: false)
            return posts.count
        case ProfileViewFilterType.feed:
            toggleNoPostsLabel(posts: self.friendFeedPosts, loading: self.friendFeedLoading)
            return self.friendFeedPosts.count
        case ProfileViewFilterType.personal:
            toggleNoPostsLabel(posts: self.personalPosts, loading: self.personalPostsLoading)
            return self.personalPosts.count
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
            if reactionsCount < 1 {
                cell.commentCountLabel.text = "no comments"
            } else if reactionsCount < 2 {
                cell.commentCountLabel.text = "\(reactionsCount) comment"
            } else {
                cell.commentCountLabel.text = "\(reactionsCount) comments"
            }
            
            return cell
            
        case ProfileViewFilterType.feed:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
            
            let post = self.friendFeedPosts[indexPath.row]
            cell.messageLabel.text = "Left a wanderpost near \(self.friendFeedPosts[indexPath.row].locationDescription)."
            cell.dateAndTimeLabel.text = post.dateAndTime
            if let user = post.wanderUser {
                cell.profileImageView.image = UIImage(data: user.userImageData)
                cell.nameLabel.text = user.username
                
            }
            return cell
            
        case ProfileViewFilterType.personal:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
            
            let post = self.personalPosts[indexPath.row]
            cell.messageLabel.text = "Left you a wanderpost near \(self.personalPosts[indexPath.row].locationDescription)."
            cell.dateAndTimeLabel.text = post.dateAndTime
            if let user = post.wanderUser {
                cell.profileImageView.image = UIImage(data: user.userImageData)
                cell.nameLabel.text = user.username
                
            }
            return cell
        }
    }
}

// MARK: - TableViewDelegate Methods
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let segmentedControlHeaderFooterView = (self.postTableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentedControlHeaderFooterView.identifier) as? SegmentedControlHeaderFooterView)!
        self.segmentedControl = segmentedControlHeaderFooterView.segmentedControl
        self.segmentedControl.delegate = self
        
        return segmentedControlHeaderFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForSectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.profileViewFilterType{
        case ProfileViewFilterType.posts:
            
            guard let selectedWanderPost = self.wanderPosts?[indexPath.row] else { return }
            let detailPostViewWithCommentsViewController = DetailPostViewWithCommentsViewController()
            detailPostViewWithCommentsViewController.wanderPost = selectedWanderPost
            detailPostViewWithCommentsViewController.deletePostFromProfileDelegate = self
            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationController?.pushViewController(detailPostViewWithCommentsViewController, animated: true)
            
        case ProfileViewFilterType.feed:
            print(ProfileViewFilterType.feed.rawValue)
        case ProfileViewFilterType.personal:
            print(ProfileViewFilterType.personal.rawValue)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

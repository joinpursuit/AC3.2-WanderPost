//
//  DetailPostViewController.swift
//  Wandr
//
//  Created by Ana Ma on 3/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

protocol RemovePostDelegate {
    func deletePost(post: WanderPost)
}

class DetailPostViewWithCommentsViewController: UIViewController {
    
    internal var wanderPost: WanderPost!
    fileprivate var wanderUser: WanderUser!
    fileprivate var reactions: [Reaction] = [Reaction]() {
        didSet {
            self.emptyState = reactions.isEmpty ? true : false
        }
    }
    
    fileprivate let textFieldContainerHeight: CGFloat = 52
    
    fileprivate var emptyState: Bool = true
    
    internal var deletePostFromProfileDelegate: RemovePostDelegate!
    fileprivate var deletePostFromMapDelegate: RemovePostDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = StyleManager.shared.accent
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white
        
        let nav = tabBarController?.viewControllers?[1] as! UINavigationController
        self.deletePostFromMapDelegate = nav.viewControllers.first as! MapViewController

        
        setupTableView()
        setupViewHierarchy()
        configureConstraints()
        
        self.wanderUser = CloudManager.shared.currentUser
        
        //TODO: Make the comments not take forever. 
        
        registerForNotifications()
        
        // check to see if the post belongs to the user to enable delete functionality
        
        if  self.wanderPost?.user.recordName == "__defaultOwner__" {
            
            let deleteButton = UIBarButtonItem(image: UIImage(named: "trash_white")!, style: .done, target: self, action: #selector(deleteButtonTapped))
            self.navigationItem.rightBarButtonItem = deleteButton
            self.wanderPost?.wanderUser = CloudManager.shared.currentUser
        }
        
        // get all reactions
        if let validReactions = self.wanderPost.reactions  {
            self.reactions = validReactions
        }
    }

    // MARK: - Helper Functions
    func toggleNoCommentsLabel(comments: [Reaction]) {
        if comments.isEmpty {
            noCommentsLabel.isHidden = false
            commentTableView.isScrollEnabled = false
        } else {
            noCommentsLabel.isHidden = true
            commentTableView.isScrollEnabled = true
        }
    }
    
    //MARK: - Actions
    func doneButtonPressed (sender: UIButton) {
        sender.animate()
        if let content = self.commentTextField.text,
            let post = self.wanderPost,
            content != "" {
            print("Content: \(content)")
            let reaction = Reaction(type: .comment, content: content, postID: post.postID)
            CloudManager.shared.addReaction(to: post, comment: reaction) { (error) in
                //add fail alert
                if error != nil {
                    let errorAlertController = UIAlertController(title: "Opps!", message: "Error while posting", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                    errorAlertController.addAction(okayAction)
                    DispatchQueue.main.async {
                        self.present(errorAlertController, animated: true, completion: nil)
                    }
                    print(error!.localizedDescription)
                }
                // adding the reaction to the post so that it will appear on profileView
                if let _ = self.wanderPost.reactions {
                    self.wanderPost.reactions!.append(reaction)
                } else {
                    self.wanderPost.reactions = [reaction]
                }
                DispatchQueue.main.async {
                    self.reactions.append(reaction)
                    self.commentTextField.text = nil
                    self.view.endEditing(true)
                    self.commentTableView.reloadData()
                    //need to scroll tableView to bottom
                }
            }
        }
        else {
            //add alert to say empty comment
                let errorAlertController = UIAlertController(title: "Opps!", message: "Your comment is empty/ no valid post present", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                errorAlertController.addAction(okayAction)
                self.present(errorAlertController, animated: true, completion: nil)
            return
        }
    }
    
    func deleteButtonTapped() {
        if let postToDelete = self.wanderPost {
            // delete this post
            let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
            let yesAlertAction = UIAlertAction(title: "Yes", style: .default, handler: { (actionAlert) in
                CloudManager.shared.delete(wanderpost: postToDelete, completion: { (error) in
                    if error != nil {
                        //handle error
                        print(error)
                    }
                    DispatchQueue.main.async {
                        self.deletePostFromMapDelegate.deletePost(post: postToDelete)
                        self.deletePostFromProfileDelegate.deletePost(post: postToDelete)
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            })
            let noAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            deleteAlert.addAction(noAlertAction)
            deleteAlert.addAction(yesAlertAction)
            
            self.present(deleteAlert, animated: true, completion: { 
                print("completion handler for alert triggered")
            })
        }
    }
    
    // MARK: - Keyboard Notification
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func keyboardDidAppear(notification: Notification) {
        self.shouldShowKeyboard(show: true, notification: notification, completion: nil)
    }
    
    internal func keyboardWillDisappear(notification: Notification) {
        self.shouldShowKeyboard(show: false, notification: notification, completion: nil)
    }
    
    private func shouldShowKeyboard(show: Bool, notification: Notification, completion: ((Bool) -> Void)? ) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationNumber = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            let animationOption = UIViewAnimationOptions(rawValue: animationNumber.uintValue)
            if show {
                self.textFieldContainerView.snp.remakeConstraints({ (view) in
                    view.top.equalTo(self.commentTableView.snp.bottom)
                    view.leading.trailing.equalToSuperview()
                    view.height.equalTo(52.0)
                    view.bottom.equalTo(keyboardFrame.size.height * -1)
                })
            } else {
                self.textFieldContainerView.snp.remakeConstraints({ (view) in
                    view.top.equalTo(self.commentTableView.snp.bottom)
                    view.leading.trailing.equalToSuperview()
                    view.height.equalTo(52.0)
                    view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
                })
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOption, animations: {
                self.view.layoutIfNeeded()
            }, completion: completion)
        }
    }

    // Mark: - Setup View Hierarchy
    private func setupViewHierarchy() {
        self.view.addSubview(commentTableView)
        self.view.addSubview(textFieldContainerView)
        self.view.addSubview(noCommentsLabel)
        
        self.textFieldContainerView.addSubview(accentBarView)
        self.textFieldContainerView.addSubview(commentTextField)
        self.textFieldContainerView.addSubview(doneButton)
        
    }

    // Mark: - Configure Constraints
    private func configureConstraints() {
        
        commentTableView.snp.makeConstraints { (tableView) in
            tableView.top.leading.trailing.equalToSuperview()
        }
        
        textFieldContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.commentTableView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            view.height.equalTo(self.textFieldContainerHeight)
        }
        
        accentBarView.snp.makeConstraints { (view) in
            view.top.leading.trailing.equalToSuperview()
            view.height.equalTo(2.0)
        }
        
        commentTextField.snp.makeConstraints { (textField) in
            textField.top.equalTo(self.accentBarView.snp.bottom)
            textField.leading.equalToSuperview().offset(8.0)
            textField.bottom.equalToSuperview()
        }
        
        doneButton.snp.makeConstraints { (button) in
            button.top.equalTo(self.accentBarView.snp.bottom).offset(8.0)
            button.leading.equalTo(self.commentTextField.snp.trailing).offset(8.0)
            button.trailing.bottom.equalToSuperview().inset(8.0)
        }
        
    }
    
    // MARK: - TableView Cell and Header Customizations
    func setupTableView() {
        //TableViewCell
        self.commentTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)
        self.commentTableView.register(ProfileViewViewControllerDetailPostTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier)
        
        self.commentTableView.register(CommentsSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: CommentsSectionHeaderView.identifier)
        
        //TableViewSectionHeader MKMapView
        self.tableHeaderContainerView.addSubview(self.mapView)
        
        self.mapView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.trailing.equalToSuperview()
            view.bottom.equalToSuperview()
        }
        
        //TableViewHeader
        self.tableHeaderContainerView.frame = CGRect(x: 0, y: 0, width: self.commentTableView.frame.size.width, height: self.view.frame.size.height * 0.3)

        //MapView in tableHeaderContainerView
        self.mapView.mapType = .standard
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = false
        self.mapView.tintColor = StyleManager.shared.accent
        self.mapView.delegate = self
        commentTableView.tableHeaderView = self.tableHeaderContainerView
        
        //Annotation in MapView
        let postAnnotation = PostAnnotation()
        postAnnotation.wanderpost = self.wanderPost
        guard let postLocation = self.wanderPost.location else { return }
        postAnnotation.coordinate = postLocation.coordinate
        postAnnotation.title = self.wanderPost.content as? String
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: postLocation.coordinate, span: span)
        let location2D = CLLocationCoordinate2DMake(postLocation.coordinate.latitude, postLocation.coordinate.longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: location2D, fromEyeCoordinate: location2D, eyeAltitude: 40)
        mapCamera.altitude = 500 // example altitude
        mapCamera.pitch = 45
        self.mapView.camera = mapCamera
        self.mapView.setRegion(region, animated: false)
        DispatchQueue.main.async {
            self.mapView.addAnnotation(postAnnotation)
        }
    }
    
    //MARK: - Views
    lazy var commentTableView: UITableView = {
        //If it's UITableViewStyle.grouped, the section is black
       let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.backgroundColor = StyleManager.shared.primaryLight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 94, bottom: 0, right: 16)
        return tableView
    }()
    
    lazy var tableHeaderContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.delegate = self
        textField.placeholder = "add a comment..."
        return textField
    }()
    
    lazy var doneButton: WanderButton = {
        let button = WanderButton(title: "done")
        button.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var textFieldContainerView: UIView = {
       let view = UIView()
        return view
    }()
    
    lazy var accentBarView: UIView = {
       let view = UIView()
        view.backgroundColor = StyleManager.shared.accent
        return view
    }()
    
    lazy var noCommentsLabel: UILabel = {
        let view = UILabel()
        view.text = "No comments to display\n"
        view.numberOfLines = 3
        view.backgroundColor = StyleManager.shared.primaryLight
        view.textColor = StyleManager.shared.primaryDark
        view.font = StyleManager.shared.comfortaaFont16
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    
}

// MARK: - TextFieldDelegate
extension DetailPostViewWithCommentsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// MARK: - MKMapViewDelegate 
extension DetailPostViewWithCommentsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // this is to check to see if the annotation is for the users location, the else block sets the post pins
        if annotation is MKUserLocation {
            return nil
        } else {
            let annotationIdentifier = "AnnotationIdentifier"
            let mapAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? WanderMapAnnotationView ?? WanderMapAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            mapAnnotationView.profileImageView.image = nil
            let postAnnotation = annotation as! PostAnnotation
            
            if let thisUser = postAnnotation.wanderpost.wanderUser {
                mapAnnotationView.profileImageView.image = UIImage(data: thisUser.userImageData)
            }
            return mapAnnotationView
        }
    }
}

// MARK: - UITableViewDataSource
extension DetailPostViewWithCommentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return self.reactions.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
            let currentReaction = self.reactions[indexPath.row]
            cell.messageLabel.text = currentReaction.content
            cell.dateAndTimeLabel.text = currentReaction.dateAndTime
            CloudManager.shared.getUserInfo(for: currentReaction.userID) { (user, error) in
                guard let validUser = user else { return }
                dump(validUser)
                DispatchQueue.main.async {
                    cell.nameLabel.text = validUser.username
                    cell.profileImageView.image = UIImage(data: validUser.userImageData)
                    print(validUser.username)
                }
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailPostTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailPostTableViewCell
            cell.locationLabel.numberOfLines = 0
            cell.locationLabel.text = self.wanderPost.locationDescription
            cell.messageLabel.text = self.wanderPost.content as? String
            cell.dateAndTimeLabel.text = self.wanderPost.dateAndTime
            cell.commentCountLabel.text = ""
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailPostViewWithCommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 30
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let commentHeader = self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: CommentsSectionHeaderView.identifier) as! CommentsSectionHeaderView
            commentHeader.sectionNameLabel.text = self.emptyState ? "    no comments" : "    comments"
            return commentHeader
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

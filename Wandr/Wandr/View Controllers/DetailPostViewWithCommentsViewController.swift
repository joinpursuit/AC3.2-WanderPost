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

class DetailPostViewWithCommentsViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var wanderPost: WanderPost!
    var wanderUser: WanderUser!
    var reactions: [Reaction] = [Reaction]()
    
    var dummyDataComments = [1,2,3,4,5,6,7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = StyleManager.shared.accent
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white
        setupViewHierarchy()
        configureConstraints()
        
        self.wanderUser = CloudManager.shared.currentUser
        
        setUpMapViewHeader()
        
        //TableViewCell
        self.commentTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)
        
        registerForNotifications()
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        // check to see if the post belongs to the user to enable delete functionality
        if CloudManager.shared.currentUser?.id == self.wanderPost?.user {
            let deleteButton = UIBarButtonItem(image: UIImage(named: "trash_white")!, style: .done, target: self, action: #selector(deleteButtonTapped))
            self.navigationItem.rightBarButtonItem = deleteButton
            self.wanderPost?.wanderUser = CloudManager.shared.currentUser
        }
        
        // get all reactions
        guard let validReactions = self.wanderPost.reactions else { return }
        self.reactions = validReactions

    }
    
    
    func setUpMapViewHeader() {
        //TableViewSectionHeader MKMapView
        self.mapHeaderContainerView.addSubview(self.mapView)
        self.mapHeaderContainerView.addSubview(self.postView)
        
        self.mapView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.6)
        }
        self.postView.snp.makeConstraints { (view) in
            view.top.equalTo(self.mapView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        
        //PostView
        self.postView.locationLabel.numberOfLines = 0
        self.postView.locationLabel.text = self.wanderPost.locationDescription
        self.postView.messageLabel.text = self.wanderPost.content as? String
        self.postView.dateAndTimeLabel.text = self.wanderPost.dateAndTime
        self.postView.commentCountLabel.text = ""
        
        self.mapHeaderContainerView.frame = CGRect(x: 0, y: 0, width: self.commentTableView.frame.size.width, height: self.view.frame.size.height * 0.5)
        
        //MapView
        //let mapViewFrame = CGRect(x: 0, y: 0, width: commentTableView.frame.size.width, height: 150.0)
        //self.mapView = MKMapView(frame: mapViewFrame)
        self.mapView.mapType = .standard
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.showsBuildings = false
        self.mapView.showsUserLocation = false
        self.mapView.tintColor = StyleManager.shared.accent
        commentTableView.tableHeaderView = self.mapHeaderContainerView
        self.mapView.delegate = self
        
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

    // MARK: - MKMapView
    
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

    
    //MARK: - Actions
    func doneButtonPressed () {
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
                    self.present(errorAlertController, animated: true, completion: nil)
                    print(error!.localizedDescription)
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
        }
    }
    
    // MARK: - TextFieldDelegate
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
    
    // MARK: - Actions
    func addCommentDoneTapped() {
        if let commentText = commentTextField.text {
            print(commentText)
            
            // this is where we put up the comment
        }
        commentTextField.text = nil
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
            view.height.equalTo(52)
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
    
    // MARK: - UITableViewDelegate and UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
        let currentReaction = self.reactions[indexPath.row]
        cell.messageLabel.text = currentReaction.content
        cell.dateAndTimeLabel.text = currentReaction.dateAndTime
        CloudManager.shared.getUserInfo(for: currentReaction.userID) { (user, error) in
            guard let validUser = user else { return }
            DispatchQueue.main.async {
                cell.nameLabel.text = validUser.username
                cell.profileImageView.image = UIImage(data: validUser.userImageData)
                print(validUser.username)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Lazy Vars
    lazy var commentTableView: UITableView = {
        //If it's UITableViewStyle.grouped, the section is black
       let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        return tableView
    }()
    
    lazy var mapHeaderContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()

    lazy var postView: PostView = {
        let view = PostView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.delegate = self
        textField.placeholder = "Comment"
        return textField
    }()
    
    lazy var textFieldOnKeyboardView: WanderTextField = {
        let textField = WanderTextField()
        textField.delegate = self
        textField.placeholder = "Comment"
        return textField
    }()
    
    lazy var doneButton: WanderButton = {
        let button = WanderButton(title: "done")
        button.addTarget(self, action: #selector(addCommentDoneTapped), for: .touchUpInside)
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
    
}

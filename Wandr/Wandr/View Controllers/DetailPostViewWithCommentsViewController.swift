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
    
    var dummyDataComments = [1,2,3,4,5,6,7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        self.view.backgroundColor = UIColor.white
        setupViewHierarchy()
        configureConstraints()
        
        //TableViewHeader
        self.commentTableView.register(PostHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: PostHeaderFooterView.identifier)
        
        //TableViewSectionHeader MKMapView
        let mapViewFrame = CGRect(x: 0, y: 0, width: commentTableView.frame.size.width, height: 150.0)
        self.mapHeaderView = MKMapView(frame: mapViewFrame)
        self.mapHeaderView.mapType = .standard
        self.mapHeaderView.isScrollEnabled = false
        self.mapHeaderView.isZoomEnabled = false
        self.mapHeaderView.showsBuildings = false
        self.mapHeaderView.showsUserLocation = false
        self.mapHeaderView.tintColor = StyleManager.shared.accent
        commentTableView.tableHeaderView = self.mapHeaderView
        self.mapHeaderView.delegate = self
        
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
        self.mapHeaderView.camera = mapCamera
        self.mapHeaderView.setRegion(region, animated: false)
        DispatchQueue.main.async {
            self.mapHeaderView.addAnnotation(postAnnotation)
        }
        
        //TableViewCell
        self.commentTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)
        
        registerForNotifications()
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    //MARK: - Actions
    
    func doneButtonPressed () {
        guard let content = self.commentTextField.text,
              let post = self.wanderPost else {
            //add alert to say empty comment
            return
        }
        
        let reaction = Reaction(type: .comment, content: content, postID: post.postID)
        CloudManager.shared.addReaction(to: post, comment: reaction) { (error) in
            //add fail alert
            print(error)
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

    // MARK: - TableView Header And Footer Customizations
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let postHeaderFooterView = (self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: PostHeaderFooterView.identifier) as? PostHeaderFooterView)!
        if let validWanderPost = self.wanderPost {
            postHeaderFooterView.locationLabel.text = validWanderPost.locationDescription
            postHeaderFooterView.messageLabel.text = validWanderPost.content as? String
            postHeaderFooterView.dateAndTimeLabel.text = validWanderPost.dateAndTime
        }
        postHeaderFooterView.backgroundView?.backgroundColor = UIColor.white
        self.postHeaderFooterView = postHeaderFooterView
        return postHeaderFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(commentTableView)
        self.view.addSubview(textFieldContainerView)
        
        self.textFieldContainerView.addSubview(accentBarView)
        self.textFieldContainerView.addSubview(commentTextField)
        self.textFieldContainerView.addSubview(doneButton)
        
    }
    
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
        guard let validReactions = self.wanderPost.reactions else { return 0 }
        return validReactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
        guard let reactions = self.wanderPost?.reactions else {
            
            return cell
        
        }
        let currentReaction = reactions[indexPath.row]
        cell.locationLabel.text = "Location:"
        cell.messageLabel.text = currentReaction.content
        cell.dateAndTimeLabel.text = currentReaction.time.description
        cell.nameLabel.text = currentReaction.userID.recordName
        return cell
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
    
    lazy var mapHeaderView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()

    lazy var postHeaderFooterView: PostHeaderFooterView = {
        let view = PostHeaderFooterView()
        return view
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.delegate = self
        textField.placeholder = "Comment"
        return textField
    }()
    
//    lazy var viewOnKeyboardView: UIView = {
//       let view = UIView()
//        view.backgroundColor = UIColor.darkGray
//        view.frame = CGRect(x: 0, y: 0, width: 10, height: 44)
//        return view
//    }()
    
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

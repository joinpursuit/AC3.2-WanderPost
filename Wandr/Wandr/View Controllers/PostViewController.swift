//
//  PostViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import CloudKit

protocol AddNewWanderPostDelegate {
    func addNewPost(post: WanderPost)
}

class PostViewController: UIViewController {
    
    fileprivate let segmentTitles = PrivacyLevel.orderedStrings()
    fileprivate let privacyLevelArray = PrivacyLevel.ordered()
    
    internal var location: CLLocation!
    internal var newPostDelegate: AddNewWanderPostDelegate!
    fileprivate var recipient: WanderUser? = nil
    fileprivate var potentialRecipients: [WanderUser] = [WanderUser]()
    
    private let standardMargin: CGFloat = 16
    private let profileHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViewHierarchy()
        configureConstraints()
        setProfileImage()
        
        userTextField.becomeFirstResponder()
        userTextField.delegate = self
    }
    
    // MARK: - Layout
    private func setupViewHierarchy() {
        self.view.backgroundColor = StyleManager.shared.primary
        self.view.addSubview(postContainerView)
        self.postContainerView.addSubview(profileImageView)
        self.postContainerView.addSubview(segmentedControlContainerView)
        self.postContainerView.addSubview(userTextField)
        self.postContainerView.addSubview(postTextView)
        self.postContainerView.addSubview(postButton)
        self.postContainerView.addSubview(dismissButton)
        self.postContainerView.addSubview(searchFriendTableView)
        
        self.segmentedControlContainerView.addSubview(segmentedControl)
    }
    
    private func configureConstraints() {
        postContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { (button) in
            button.top.equalToSuperview().offset(standardMargin)
            button.trailing.equalToSuperview().inset(standardMargin)
            button.height.equalTo(profileHeight)
            button.width.equalTo(profileHeight)
        }
        
        profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(standardMargin)
            view.leading.equalToSuperview().offset(standardMargin)
            view.height.equalTo(profileHeight)
            view.width.equalTo(profileHeight)
        }
        
        segmentedControlContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(8)
            view.leading.equalToSuperview().offset(standardMargin + 12)
            view.trailing.equalToSuperview().inset(standardMargin + 12)
            view.height.equalTo(30)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.trailing.leading.bottom.equalToSuperview()
        }
        
        userTextField.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(standardMargin)
            view.top.equalTo(segmentedControl.snp.bottom).offset(standardMargin)
            view.trailing.equalToSuperview().inset(standardMargin)
            view.height.equalTo(1)
        }
        
        postTextView.snp.makeConstraints { (view) in
            view.top.equalTo(userTextField.snp.bottom).offset(standardMargin)
            view.leading.equalToSuperview().offset(standardMargin)
            view.trailing.equalToSuperview().inset(standardMargin)
            view.height.equalToSuperview().multipliedBy(0.25)
        }
        
        postButton.snp.makeConstraints { (button) in
            button.top.equalTo(postTextView.snp.bottom).offset(8)
            button.trailing.equalToSuperview().inset(standardMargin)
        }
        
        searchFriendTableView.snp.makeConstraints { (view) in
            view.top.equalTo(self.userTextField.snp.bottom)
            view.leading.equalTo(self.userTextField.snp.leading)
            view.trailing.equalTo(self.userTextField.snp.trailing)
            view.bottom.equalTo(self.postButton.snp.bottom)
        }
    }
    
    func setProfileImage() {
        if let validOriginalImage = UIImage(data: CloudManager.shared.currentUser!.userImageData) {
            //Do not delete becase imageToDisplay will be the long term solution
            let imageToDisplay = validOriginalImage.fixRotatedImage()
            //let tempRotateSolution = UIImage(cgImage: validOriginalImage.cgImage!, scale: validOriginalImage.scale, orientation: UIImageOrientation.right)
            self.profileImageView.image = imageToDisplay
        }
    }
    
    // MARK: - Actions
    func dismissButtonPressed(_ sender: UIButton) {
        self.resignFirstResponder()
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func postButtonPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            sender.transform = CGAffineTransform.identity
                        }
        })
        
        //init post, this is going to be a rough sketch of doing it
        guard self.postTextView.text!.characters.count > 0,
            postTextView.textColor != StyleManager.shared.placeholderText else {
                AlertFactory.init(for: self).makeCustomOKAlert(title: "No Content", message: "Please write something to post.")
                return
        }
        
        let content = self.postTextView.text as AnyObject
        let privacy = privacyLevelArray[segmentedControl.selectedSegmentIndex]
        
        switch privacy {
        case .personal:
            if self.recipient == nil {
                AlertFactory.init(for: self).makeCustomOKAlert(title: "No User", message: "Please enter a recipient for this personal post.")
                return
            }
        default:
            self.recipient = nil
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            if let error = error {
                print("error with geocoder: \(error)")
            }
            
            if let marks = placemarks, let thisMark = marks.last {
                let locationDescription = thisMark.readableDescription
                
                let post = WanderPost(location: self.location,
                                      content: content,
                                      contentType: .text,
                                      privacyLevel: privacy,
                                      locationDescription: locationDescription,
                                      recipient: self.recipient?.id)
                
                
                CloudManager.shared.createPost(post: post, to: self.recipient) { (record, errors) in
                    if errors != nil {
                        print(errors!)
                        //TODO Add in error handling.
                    }
                    
                    if let validRecord = record, let thisPost = WanderPost(withCKRecord: validRecord) {
                        // adds this post to the mapViewController and animates pin drop
                        thisPost.wanderUser = CloudManager.shared.currentUser
                        self.newPostDelegate.addNewPost(post: thisPost)
                    }
                }
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func toggleUserTextField(show: Bool) {
        let height = show ? 44 : 1
        let multipler = show ? 0.2 : 0.25
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            self.userTextField.snp.remakeConstraints { (view) in
                view.leading.equalToSuperview().offset(self.standardMargin)
                view.top.equalTo(self.segmentedControl.snp.bottom).offset(self.standardMargin)
                view.trailing.equalToSuperview().inset(self.standardMargin)
                view.height.equalTo(height)
            }
            self.postTextView.snp.remakeConstraints { (view) in
                view.top.equalTo(self.userTextField.snp.bottom).offset(self.standardMargin)
                view.leading.equalToSuperview().offset(self.standardMargin)
                view.trailing.equalToSuperview().inset(self.standardMargin)
                view.height.equalToSuperview().multipliedBy(multipler)
            }
            self.postContainerView.layoutIfNeeded()
        }
        if show {
            self.userTextField.isHidden = false
        } else {
            animator.addCompletion({ (_) in
                self.userTextField.isHidden = true
            })
        }
        animator.startAnimation()
        
    }
    
    //MARK: - Setup TableView
    func setupTableView() {
        self.searchFriendTableView.register(ProfileFriendTableViewCell.self, forCellReuseIdentifier: ProfileFriendTableViewCell.identifier)
    }
    
    //MARK: - TextField Action Methods
    func textFieldChanged(_ textField: UITextField) {
        self.searchFriendTableView.isHidden = userTextField.text?.isEmpty ?? false
    }
    
    //MARK: - Views
    lazy var postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleManager.shared.primaryLight
        return view
    }()
    
    lazy var profileImageView: WanderProfileImageView = {
        let imageView = WanderProfileImageView(width: self.profileHeight, height: self.profileHeight)
        return imageView
    }()
    
    lazy var segmentedControlContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var segmentedControl: WanderSegmentedControl = {
        let control = WanderSegmentedControl()
        control.delegate = self
        control.backgroundColor = UIColor.clear
        control.setSegmentItems(self.segmentTitles)
        return control
    }()
    
    lazy var postTextView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1
        view.layer.borderColor = StyleManager.shared.primaryDark.cgColor
        view.layer.cornerRadius = 10
        view.delegate = self
        view.font = UIFont.systemFont(ofSize: 18)
        view.text = "write something to post..."
        view.textColor = StyleManager.shared.placeholderText
        view.tintColor = StyleManager.shared.accent
        return view
    }()
    
    lazy var userTextField: WanderTextField = {
        let field = WanderTextField()
        field.border(placeHolder: "enter username...")
        field.textColor = StyleManager.shared.primaryText
        field.font = UIFont.systemFont(ofSize: 18)
        field.accessibilityIdentifier = "username"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.isHidden = true
        
        //Add target for editingChanged
        field.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return field
    }()
    
    lazy var postButton: WanderButton = {
        let button = WanderButton(title: "post", spacing: 22)
        button.addTarget(self, action: #selector(postButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var searchFriendTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
}

// MARK: - TwicketSegmentedControlDelegate Method
extension PostViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0, 1:
            toggleUserTextField(show: false)
        case 2:
            toggleUserTextField(show: true)
        default:
            print("Can not make a decision")
        }
        self.searchFriendTableView.isHidden = true
    }
}

// MARK: - UITableViewDataSource Methods
extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.potentialRecipients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileFriendTableViewCell.identifier, for: indexPath) as! ProfileFriendTableViewCell
        
        let recipient = self.potentialRecipients[indexPath.row]
        cell.addRemoveFriendButton.isHidden = true
        cell.nameLabel.text = recipient.username
        cell.profileImageView.image = UIImage(data: recipient.userImageData)
        return cell
    }
}

// MARK: - UITableViewDelegate Method
extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recipient = self.potentialRecipients[indexPath.row]
        guard let validRecipient = self.recipient else { return }
        self.userTextField.text = "\(validRecipient.username)"
        self.searchFriendTableView.isHidden = true
    }
}

// MARK: - UITextFieldDelegate Methods
extension PostViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CloudManager.shared.search(for: textField.text! + string) { (wanderUsers, error) in
            if error != nil {
                AlertFactory.init(for: self).makeDefaultOKAlert()
            }
            if let validUsers = wanderUsers {
                print(validUsers.count)
                self.potentialRecipients = validUsers
                self.recipient = validUsers[0]
            }
            DispatchQueue.main.async {
                self.searchFriendTableView.reloadData()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchFriendTableView.isHidden = true
        self.potentialRecipients = []
    }
}

// MARK: - UITextViewDelegate Methods
extension PostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == StyleManager.shared.placeholderText {
            textView.text = nil
            textView.textColor = StyleManager.shared.primaryText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "write something to post..."
            textView.textColor = StyleManager.shared.placeholderText
        }
    }
}


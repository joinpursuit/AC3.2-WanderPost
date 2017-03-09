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
    
    var wanderPost: WanderPost?
    
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
        guard let postLocation = self.wanderPost?.location else { return }
        postAnnotation.coordinate = postLocation.coordinate
        postAnnotation.title = self.wanderPost?.content as? String
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

        
        //let customView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
        //customView.backgroundColor = UIColor.red
        //commentTextField.inputAccessoryView = customView
        
        //let textFieldFake = UITextField(frame: CGRect.zero)
        //self.view.addSubview(textFieldFake)
        //let viewOnKeyboardView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 39.0))
        //viewOnKeyboardView.backgroundColor = UIColor.darkGray
        //let textField = UITextField(frame: CGRect(x: 0.0, y: 4.0, width: 300.0, height: 31.0))
        //textField.borderStyle = UITextBorderStyle.roundedRect
        //textField.font = UIFont.systemFont(ofSize: 24.0)
        //textField.delegate = self
        //viewOnKeyboardView.addSubview(textField)
        //textFieldFake.inputAccessoryView = viewOnKeyboardView
        //textFieldFake.becomeFirstResponder()
        
        //commentTextField.inputAccessoryView = self.viewOnKeyboardView
        /*
    CGRect rectFake = CGRectZero;

    UITextField *fakeField = [[UITextField alloc] initWithFrame:rectFake];

    [self.view addSubview:fakeField];

    UIView *av = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 39.0)];

    av.backgroundColor = [UIColor darkGrayColor];

    CGRect rect = CGRectMake(200.0, 4.0, 400.0, 31.0);

    UITextField *textField = [[UITextField alloc] initWithFrame:rect];

    textField.borderStyle = UITextBorderStyleRoundedRect;

    textField.font = [UIFont systemFontOfSize:24.0];

    textField.delegate = self;

    [av addSubview:textField];

    fakeField.inputAccessoryView = av;

    [fakeField becomeFirstResponder];

 */
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }

    // MARK: - TableView Header And Footer Customizations
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let postHeaderFooterView = (self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: PostHeaderFooterView.identifier) as? PostHeaderFooterView)!
        if let validWanderPost = self.wanderPost {
            postHeaderFooterView.locationLabel.text = validWanderPost.locationDescription
            postHeaderFooterView.messageLabel.text = validWanderPost.content as? String
            postHeaderFooterView.dateAndTimeLabel.text = validWanderPost.dateAndTime
        }
        postHeaderFooterView.backgroundColor = UIColor.gray
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
        
        //self.viewOnKeyboardView.addSubview(self.textFieldOnKeyboardView)
        //self.viewOnKeyboardView.addSubview(self.doneButton)
    }
    
    private func configureConstraints() {
        commentTableView.snp.makeConstraints { (tableView) in
            tableView.top.leading.trailing.equalToSuperview()
        }
        
        textFieldContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.commentTableView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            view.height.equalTo(60)
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
        
        //Stuff in onKeyboardView
//        textFieldOnKeyboardView.snp.makeConstraints { (textField) in
//            textField.leading.top.bottom.equalToSuperview()
//        }
//        
//        doneButton.snp.makeConstraints { (button) in
//            button.leading.equalTo(self.textFieldOnKeyboardView.snp.trailing)
//            button.top.bottom.trailing.equalToSuperview()
//        }
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyDataComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier, for: indexPath) as! ProfileViewViewControllerDetailFeedTableViewCell
        cell.locationLabel.text = "Location:"
        return cell
    }
    
    lazy var commentTableView: UITableView = {
       let tableView = UITableView()
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
    
    lazy var viewOnKeyboardView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.frame = CGRect(x: 0, y: 0, width: 10, height: 44)
        return view
    }()
    
    lazy var textFieldOnKeyboardView: WanderTextField = {
        let textField = WanderTextField()
        textField.delegate = self
        textField.placeholder = "Comment"
        return textField
    }()
    
    lazy var doneButton: WanderButton = {
        let button = WanderButton(title: "done")
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

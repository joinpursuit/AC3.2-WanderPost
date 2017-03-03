//
//  MapViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit
import TwicketSegmentedControl
import UserNotifications

protocol ARPostDelegate {
    var posts: [WanderPost] { get set }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UNUserNotificationCenterDelegate {
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var wanderposts: [WanderPost]? {
        didSet {
            self.arDelegate.posts = self.wanderposts!
        }
    }
    
    let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    var arDelegate: ARPostDelegate!
    var addPostViewShown = false
    var lastUpdatedLocation: CLLocation!
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "wanderpost"
        //Make this more dynamic
        self.arDelegate = tabBarController?.viewControllers?.last as! CameraViewController
        self.lastUpdatedLocation = locationManager.location!
        setupViewHierarchy()
        configureConstraints()
        configureTwicketSegmentControl()
        setupLocationManager()
        getWanderPosts(lastUpdatedLocation)
        //        setupGestures()
        userNotificationCenter.delegate = self
    }
    
    
    // MARK: - Hierarchy
    
    private func setupViewHierarchy() {
        //Map Container View
        self.view.addSubview(self.mapContainerView)
        self.mapContainerView.addSubview(mapView)
        self.mapContainerView.addSubview(addPostButton)
        
        self.view.addSubview(addPostButton)
        self.view.addSubview(segmentedControl)
    }
    
    
    // MARK: - Layout
    
    private func configureConstraints() {
        //Map Container
        mapContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.equalToSuperview()
            view.trailing.equalToSuperview()
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        mapView.snp.makeConstraints { (view) in
            view.top.leading.trailing.bottom.equalToSuperview()
        }
        
        addPostButton.snp.makeConstraints { (button) in
            button.trailing.equalToSuperview().inset(48.0)
            button.bottom.equalToSuperview().inset(54.0)
            button.width.equalTo(54.0)
            button.height.equalTo(54.0)
        }
    }
    
    // MARK: - Setup
    
    func configureTwicketSegmentControl() {
        let frame = CGRect(x: 5, y: 75, width: view.frame.width - 10, height: 30)
        self.segmentedControl = TwicketSegmentedControl(frame: frame)
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        self.segmentedControl.delegate = self
    }
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        let location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: location2D, fromEyeCoordinate: location2D, eyeAltitude: 40)
        mapCamera.altitude = 500 // example altitude
        mapCamera.pitch = 5
        mapView.camera = mapCamera
        mapView.setRegion(region, animated: false)
        
        if lastUpdatedLocation.distance(from: location) > 100 {
            lastUpdatedLocation = location
            getWanderPosts(location)
            print("new location")
            //Check for new data
            //If new data have local notification happen
//            UNNotificationRequest.init(identifier: <#T##String#>, content: <#T##UNNotificationContent#>, trigger: <#T##UNNotificationTrigger?#>)
//            UNUserNotificationCenter.current().add(<#T##request: UNNotificationRequest##UNNotificationRequest#>, withCompletionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
            
            //Notification Testing
        }
        
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Testing"
        content.body = "This is gonna be annoying"
        content.categoryIdentifier = "newPost"
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: notificationTrigger)
        userNotificationCenter.add(request) { (error) in
            print(error)
        }
        let show = UNNotificationAction(identifier: "newData", title: "WOO", options: .foreground)
        let category = UNNotificationCategory(identifier: "newPost", actions: [show], intentIdentifiers: [])
        userNotificationCenter.setNotificationCategories([category])
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    // MARK: - Actions
    
    func addPostButtonPressed(_ sender: UIButton) {
        let postVC = PostViewController()
        postVC.location = locationManager.location
        self.navigationController?.present(postVC, animated: true, completion: nil)
    }
    
    //MARK: - Lazy Vars
    
    lazy var mapContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.showsBuildings = false
        return mapView
    }()
    
    lazy var addPostButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(addPostButtonPressed), for: UIControlEvents.touchUpInside)
        button.setTitle("Add", for: .normal)
        button.layer.cornerRadius = 26
        button.layer.shadowColor = UIColor.blue.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 5
        button.clipsToBounds = false
        return button
    }()
    
    lazy var dragUpOrDownContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cheveronButton: UIButton = {
        let button = UIButton()
        button.setTitle("Up", for: .normal)
        button.tintColor = UIColor.yellow
        button.backgroundColor = UIColor.orange
        //button.addTarget(self, action: #selector(animatePostView), for: .touchDragInside)
        return button
    }()
    
    lazy var segmentedControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()
    
    
    //MARK: - Helper Functions
    
    func getWanderPosts(_ location: CLLocation) {
        CloudManager.shared.getWanderpostsForMap(location) { (posts, error) in
            if let error = error {
                print("Error fetching posts, \(error)")
            } else if let posts = posts {
                self.wanderposts = posts
                
                DispatchQueue.main.async {
                    self.reloadMapView()
                }
            }
        }
    }
    
    func reloadMapView() {
        if let posts = self.wanderposts {
            for post in posts {
                let annotaton = PostAnnotation()
                guard let postLocation = post.location else { return }
                annotaton.coordinate = postLocation.coordinate
                annotaton.title = post.content as? String
                mapView.addAnnotation(annotaton)
            }
        }
    }
    
    
    //MARK: - Notification Delegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response)
        
        
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // the user swiped to unlock
            print("Default identifier")
            
        case "show":
            // the user tapped our "show more info…" button
            print("Show more information…")
            break
            
        default:
            break
        }
        
        // you must call the completion handler when you're done
        completionHandler()
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
}

extension MapViewController: TwicketSegmentedControlDelegate {
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







//MARK: - Commented Out Code

//    func togglePostView(_ sender: UISwipeGestureRecognizer) {
//        switch sender.direction {
//        case UISwipeGestureRecognizerDirection.up where self.addPostViewShown == false:
//            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
//             self.addPostViewShown = !addPostViewShown
//        case UISwipeGestureRecognizerDirection.down where self.addPostViewShown == true:
//            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
//             self.addPostViewShown = !addPostViewShown
//        default:
//            print("Not a recognized gesture")
//        }
//    }

//    func togglePostView(_ sender: UISwipeGestureRecognizer) {
//        switch sender.direction {
//        case UISwipeGestureRecognizerDirection.up where self.addPostViewShown == false:
//            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
//             self.addPostViewShown = !addPostViewShown
//        case UISwipeGestureRecognizerDirection.down where self.addPostViewShown == true:
//            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
//             self.addPostViewShown = !addPostViewShown
//        default:
//            print("Not a recognized gesture")
//        }
//    }

//    func animatePostView() {
//        animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
//        self.addPostViewShown = !addPostViewShown
//    }

//    private func animateSettingsMenu(showPost: Bool, duration: TimeInterval, dampening: CGFloat = 0.005, springVelocity: CGFloat = 0.005) {
//        switch self.addPostViewShown {
//        case true:
//            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: dampening, initialSpringVelocity: springVelocity, options: .curveEaseOut, animations: {
//
//                self.dragUpOrDownContainerView.snp.remakeConstraints { (view) in
//                    view.leading.equalToSuperview()
//                    view.trailing.equalToSuperview()
//                    view.height.equalToSuperview().multipliedBy(0.5)
//                    view.width.equalToSuperview()
//                }
//
//                self.cheveronButton.snp.remakeConstraints { (button) in
//                    button.top.equalToSuperview()
//                    button.trailing.equalToSuperview().inset(16)
//                }
//
//                self.segmentedControlContainerView.snp.remakeConstraints { (view) in
//                    view.top.equalTo(self.cheveronButton.snp.centerY)
//                    view.leading.trailing.equalToSuperview()
//                    view.height.equalToSuperview().multipliedBy(0.175)
//                    view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
//                }
//
//                self.segmentedControl.snp.remakeConstraints { (control) in
//                    control.top.leading.bottom.trailing.equalToSuperview()
//                }
//
//                self.postContainerView.snp.remakeConstraints { (view) in
//                    view.top.equalTo(self.segmentedControlContainerView.snp.bottom)
//                    view.leading.trailing.bottom.equalToSuperview()
//                }
//
//            }, completion: nil)
//
//        case false:
//           UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: dampening, initialSpringVelocity: springVelocity, options: .curveEaseOut, animations: {
//            self.dragUpOrDownContainerView.snp.remakeConstraints({ (view) in
//                view.leading.trailing.equalToSuperview()
//                view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
//                view.height.equalToSuperview().multipliedBy(0.5)
//                view.width.equalToSuperview()
//            })
//
//            self.cheveronButton.snp.remakeConstraints { (button) in
//                button.top.equalToSuperview()
//                button.trailing.equalToSuperview().inset(16)
//            }
//
//            self.segmentedControlContainerView.snp.remakeConstraints({ (view) in
//                view.top.equalTo(self.cheveronButton.snp.centerY)
//                view.leading.trailing.equalToSuperview()
//                view.height.equalToSuperview().multipliedBy(0.175)
//            })
//
//            self.segmentedControl.snp.remakeConstraints { (control) in
//                control.top.leading.bottom.trailing.equalToSuperview()
//            }
//
//            self.postContainerView.snp.remakeConstraints { (view) in
//                view.top.equalTo(self.segmentedControlContainerView.snp.bottom)
//                view.leading.trailing.bottom.equalToSuperview()
//            }
//
//           }, completion: nil)
//        }
//    }

// Mark: - Add Gestures
//    private func setupGestures() {
//        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePostView))
//        swipeUpGesture.direction = .up
//        self.dragUpOrDownContainerView.addGestureRecognizer(swipeUpGesture)
//
//        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePostView))
//        swipeDownGesture.direction = .down
//         self.dragUpOrDownContainerView.addGestureRecognizer(swipeDownGesture)
//    }
    

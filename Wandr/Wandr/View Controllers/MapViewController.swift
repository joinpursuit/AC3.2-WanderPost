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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UNUserNotificationCenterDelegate, AddNewWanderPostDelegate {
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var allWanderPosts: [WanderPost]? {
        didSet {
            CloudManager.shared.getInfo(forPosts: self.allWanderPosts!) { (error) in
                
                print(error)
                
                DispatchQueue.main.async {
                    self.reloadMapView()
                }
            }
        }
    }
    
    var wanderposts: [WanderPost]? {
        didSet {
            self.arDelegate.posts = self.wanderposts!
            DispatchQueue.main.async {
                self.reloadMapView()
            }
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
        
        mapView.delegate = self
        userNotificationCenter.delegate = self

        //Make this more dynamic
        let nav = tabBarController?.viewControllers?.last as! UINavigationController
        self.arDelegate = nav.viewControllers.first! as! ARViewController
        
        setupViewHierarchy()
        configureConstraints()
        setupLocationManager()
        //setupGestures()
        self.lastUpdatedLocation = locationManager.location!
        getWanderPosts(lastUpdatedLocation)
        self.segmentedControl.setSegmentItems(segmentTitles)
    }
    
    
    // MARK: - Hierarchy
    
    private func setupViewHierarchy() {
        //Map Container View
        self.view.addSubview(self.mapContainerView)
        self.mapContainerView.addSubview(mapView)
        self.mapContainerView.addSubview(addPostButton)
        
        self.view.addSubview(addPostButton)
        self.view.addSubview(segmentedControlContainerView)
        self.segmentedControlContainerView.addSubview(segmentedControl)
    }
    
    
    // MARK: - Layout
    
    private func configureConstraints() {
        //Map Container
        
        self.edgesForExtendedLayout = []

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
            button.trailing.bottom.equalToSuperview().inset(32.0)
            button.width.height.equalTo(54.0)
        }
        
        segmentedControlContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom).offset(16)
            view.leading.equalToSuperview().offset(22.0)
            view.trailing.equalToSuperview().inset(22.0)
            view.height.equalTo(34)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Setup
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - AddNewWanderPostDelegate
    
    func addNewPost(post: WanderPost) {
        let myAnnotaton = PostAnnotation()
        myAnnotaton.wanderpost = post
        guard let postLocation = post.location else { return }
        myAnnotaton.coordinate = postLocation.coordinate
        if let user = post.wanderUser {
            myAnnotaton.title = user.username
        }
        mapView.addAnnotation(myAnnotaton)
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
            makeNotificationsFor(privacyLevel: .friends)
            makeNotificationsFor(privacyLevel: .message)
            print("new location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
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
            mapAnnotationView.canShowCallout = true
            
            let postAnnotation = annotation as! PostAnnotation            
            if let thisUser = postAnnotation.wanderpost.wanderUser {
                mapAnnotationView.profileImageView.image = UIImage(data: thisUser.userImageData)
            }
            return mapAnnotationView
        }
    }
    
    // MARK: - Map View Delegate Methods
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            let endFrame = view.frame
            view.frame = endFrame.offsetBy(dx: 0, dy: -500)
            UIView.animate(withDuration: 0.5, animations: { 
                view.frame = endFrame
            })
        }
    }
    
    // MARK: - Actions
    func addPostButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            sender.transform = CGAffineTransform.identity
                            let postVC = PostViewController()
                            postVC.newPostDelegate = self
                            postVC.location = self.locationManager.location
                            self.navigationController?.present(postVC, animated: true, completion: nil)
                        }
        })
        
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
        mapView.showsUserLocation = true
        mapView.tintColor = StyleManager.shared.accent
        return mapView
    }()
    
    lazy var addPostButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(addPostButtonPressed), for: UIControlEvents.touchUpInside)
        button.setImage(UIImage(named: "compose_white"), for: .normal)
        button.backgroundColor = StyleManager.shared.accent
        button.layer.cornerRadius = 26
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
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
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    lazy var segmentedControl: WanderSegmentedControl = {
        let control = WanderSegmentedControl()
        control.delegate = self
        return control
    }()
    
    //MARK: - Helper Functions
    
    func getWanderPosts(_ location: CLLocation) {
        CloudManager.shared.getWanderpostsForMap(location) { (posts, error) in
            if let error = error {
                print("Error fetching posts, \(error)")
            } else if let posts = posts {
                DispatchQueue.main.async {
                    self.wanderposts = posts
                    self.allWanderPosts = posts
                }
            }
        }
    }
    
    func reloadMapView() {
        if let posts = self.wanderposts {
            var annotations: [MKAnnotation] = []
            for post in posts {
                let myAnnotaton = PostAnnotation()
                myAnnotaton.wanderpost = post
                guard let postLocation = post.location else { return }
                myAnnotaton.coordinate = postLocation.coordinate
                if let user = post.wanderUser {
                    myAnnotaton.title = user.username
                }
                annotations.append(myAnnotaton)
            }
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
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
    
    //MARK: - Helper Functions
    
    func makeNotification(withBody body: String) {
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "New Wanderposts"
        content.body = body
        content.categoryIdentifier = "newPost"
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: notificationTrigger)
        userNotificationCenter.add(request) { (error) in
            //Add in error handling
            print(error)
        }
        let show = UNNotificationAction(identifier: "newData", title: "WOO", options: .foreground)
        let category = UNNotificationCategory(identifier: "newPost", actions: [show], intentIdentifiers: [])
        userNotificationCenter.setNotificationCategories([category])
        
    }
    
    func makeNotificationsFor(privacyLevel level: PrivacyLevel) {
        if let validWanderPosts = self.allWanderPosts?.filter({ $0.privacyLevel == level }),
            !validWanderPosts.isEmpty {
            let count = validWanderPosts.count
            var body: String = ""
            switch level {
            case .friends:
                if count > 1 {
                    body = "\(count) of your friends have left messages here!"
                } else {
                    fallthrough
                }
            case .message:
                print("hi!")
                //I see this as not working. We'll see though.
                for post in validWanderPosts where post.recipient == CloudManager.shared.currentUser?.id {
                    body = "\(post.wanderUser?.username ?? "Someone") left you a message!"
                }
            case .everyone:
               return
            }
            makeNotification(withBody: body)
        }
    }
    
    //HOW IS A POST GOING TO BE MARKED AS READ. Namely, when is it going to be marked as read -- different for private than not imo.
}

extension MapViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        guard let allValidWanderPosts = self.allWanderPosts else { return }
        let validFriends = CloudManager.shared.currentUser!.friends.map { $0.recordName }
        print(validFriends)

        
        switch segmentIndex {
        case 0:
            self.wanderposts = allValidWanderPosts
        case 1:
            let friends = allValidWanderPosts.filter{
                print($0.user)
                return $0.privacyLevel == .friends && validFriends.contains($0.user.recordName)
            
            }
            let messages = allValidWanderPosts.filter{ $0.privacyLevel == .message && $0.recipient!.recordName == CloudManager.shared.currentUser!.id.recordName }
            
            self.wanderposts = friends + messages
        case 2:
            
            self.wanderposts = allValidWanderPosts.filter{$0.privacyLevel == .message && $0.recipient?.recordName == CloudManager.shared.currentUser?.id.recordName }
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



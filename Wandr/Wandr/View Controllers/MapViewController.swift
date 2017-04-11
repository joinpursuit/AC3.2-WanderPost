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

class MapViewController: UIViewController {
    
    fileprivate var locationManager : CLLocationManager = CLLocationManager()
    
    fileprivate var allWanderPosts: [WanderPost]?
    
    fileprivate var wanderposts: [WanderPost]? {
        didSet {
            self.arDelegate.posts = self.wanderposts!
            self.reloadMapView()
        }
    }
    
    fileprivate let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    fileprivate var arDelegate: ARPostDelegate!
    fileprivate var addPostViewShown = false
    fileprivate var lastUpdatedLocation: CLLocation!
    fileprivate let userNotificationCenter = UNUserNotificationCenter.current()
    fileprivate var isNewMapAnnotation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "wanderpost"
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        self.navigationItem.rightBarButtonItem = refreshButton
        
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
    
    func refreshTapped() {
        getWanderPosts(lastUpdatedLocation)
    }
    
    //MARK: - Views
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
    
    let dragUpOrDownContainerView = UIView()
    
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
        view.backgroundColor = UIColor.clear
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
                return
            } else if let posts = posts {
                self.allWanderPosts = posts
                CloudManager.shared.getInfo(forPosts: self.allWanderPosts!) { (error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        self.didSelect(self.segmentedControl.selectedSegmentIndex)
                    }
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
                    body = "Your friends have left \(count) messages here!"
                } else {
                    fallthrough
                }
            case .personal:
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
    
    //TODO: HOW IS A POST GOING TO BE MARKED AS READ. Namely, when is it going to be marked as read -- different for private than not imo. -- post is marked read by appending the username to the readBy array maybe. marked as read as soon as you get into AR/its on your screen in AR.
}

// MARK: - RemovePostDelegate Method
extension MapViewController: RemovePostDelegate {
    func deletePost(post: WanderPost) {
        wanderposts = wanderposts!.filter { $0.postID != post.postID }
        allWanderPosts = allWanderPosts!.filter { $0.postID != post.postID }
        reloadMapView()
    }
}

// MARK: - AddNewWanderPostDelegate Method
extension MapViewController: AddNewWanderPostDelegate {
    func addNewPost(post: WanderPost) {
        self.isNewMapAnnotation = true
        let myAnnotaton = PostAnnotation()
        myAnnotaton.wanderpost = post
        
        guard let postLocation = post.location else { return }
        myAnnotaton.coordinate = postLocation.coordinate
        if let user = post.wanderUser {
            myAnnotaton.title = user.username
        }
        mapView.addAnnotation(myAnnotaton)
    }
}

// MARK: - UNUserNotificationCenterDelegate Methods
extension MapViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
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

// MARK: - MKMapViewDelegate Methods
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if isNewMapAnnotation {
            for view in views {
                let endFrame = view.frame
                view.frame = endFrame.offsetBy(dx: 0, dy: -500)
                UIView.animate(withDuration: 0.5, animations: {
                    view.frame = endFrame
                })
            }
            self.isNewMapAnnotation = false
        }
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension MapViewController: CLLocationManagerDelegate{
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
            makeNotificationsFor(privacyLevel: .personal)
            print("new location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}


// MARK: - TwicketSegmentedControlDelegate Method
extension MapViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        guard let allValidWanderPosts = self.allWanderPosts else { return }
        let validFriends = CloudManager.shared.currentUser!.friends.map { $0.recordName }

        let everyone = allValidWanderPosts.filter { $0.privacyLevel == .everyone }
        
        let friends = allValidWanderPosts.filter{
            return validFriends.contains($0.user.recordName)
        }
        
        let messages = allValidWanderPosts.filter{ $0.privacyLevel == .personal && $0.recipient?.recordName == CloudManager.shared.currentUser!.id.recordName }
        
        switch segmentIndex {
        case 0:
            self.wanderposts = everyone + friends
        case 1:
            self.wanderposts = friends + messages
        case 2:
            self.wanderposts = messages
        default:
            print("Can not make a decision")
        }
    }
}


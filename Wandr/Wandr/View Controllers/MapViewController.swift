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
    
    var allWanderPosts: [WanderPost] = []
    
    var wanderposts: [WanderPost]? {
        didSet {
            self.arDelegate.posts = self.wanderposts!
            self.reloadMapView()
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
        self.lastUpdatedLocation = locationManager.location!
        self.arDelegate = tabBarController?.viewControllers?.last as! ARViewController
        setupViewHierarchy()
        configureConstraints()
        setupLocationManager()
        getWanderPosts(lastUpdatedLocation)
        //setupGestures()
        userNotificationCenter.delegate = self
        mapView.delegate = self
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
        
        segmentedControlContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.equalToSuperview().offset(16.0)
            view.trailing.equalToSuperview().inset(16.0)
            view.height.equalTo(30)
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
            makeNotification(withBody: "hello")
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
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? WanderMapAnnotationView ?? WanderMapAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            APIRequestManager.manager.getData(endPoint: "https://randomuser.me/api/portraits/lego/\(Int(arc4random_uniform(9))).jpg") { (data) in
                if let data = data {
                    DispatchQueue.main.async {
                        annotationView.profileImageView.image = UIImage(data: data)
                    }
                }
            }
            return annotationView
        }
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
        mapView.showsUserLocation = true
        mapView.tintColor = StyleManager.shared.accent
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
                self.wanderposts = posts
                self.allWanderPosts = posts
                DispatchQueue.main.async {
                    self.reloadMapView()
                }
            }
        }
    }
    
    func reloadMapView() {
        if let posts = self.wanderposts {
            var annotations: [MKAnnotation] = []
            for post in posts {
                let annotaton = PostAnnotation()
                guard let postLocation = post.location else { return }
                annotaton.coordinate = postLocation.coordinate
                annotaton.title = post.content as? String
                annotations.append(annotaton)
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
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
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
    
    func checkForNewWanderPosts(ofType type: PrivacyLevel) {
        if let validWanderPosts = self.wanderposts {
            //figure this out
            var body: String
            switch type {
            case .friends:
                body = ""
            case .message:
                body = ""
            case .everyone:
                break
            }
        //makeNotification(withBody: <#T##String#>)
        }
    }
    
    //HOW IS A POST GOING TO BE MARKED AS READ. Namely, when is it going to be marked as read -- different for private than not imo.
}

extension MapViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            print("Everyone")
            self.wanderposts = self.allWanderPosts
            dump(self.wanderposts?.count)
        case 1:
            print("Friends")
            self.wanderposts = self.allWanderPosts.filter{$0.privacyLevel == .friends} + self.allWanderPosts.filter{$0.privacyLevel == .message}
            dump(self.wanderposts?.count)
        case 2:
            print("Message")
            self.wanderposts = self.allWanderPosts.filter{$0.privacyLevel == .message}
            dump(self.wanderposts?.count)
        default:
            print("Can not make a decision")
        }
    }
}

extension MapViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}




extension MapViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        print("Tapped view for POI: \(annotationView.titleLabel?.text)")
        //1
        //    if let annotation = annotationView.annotation as? WanderPost {
        //      //2
        //      let placesLoader = PlacesLoader()
        //
        //      // this load detail information make an api call to google places to get info.
        //      placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
        //
        //        //3
        //        if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
        //          annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
        //          annotation.website = infoDict.object(forKey: "website") as? String
        //
        //          //4
        //          self.showInfoView(forPlace: annotation)
        //        }
        //      }
        //    }
    }
    
    //  func showInfoView(forPlace place: Place) {
    //    //1
    //    let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
    //    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    //    //2
    //    arViewController.present(alert, animated: true, completion: nil)
    //  }
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



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

protocol ARPostDelegate {
    var posts: [WanderPost] { get set }
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var allWanderPosts: [WanderPost] = []
    
    var wanderposts: [WanderPost]? {
        didSet {
            self.arDelegate.posts = self.wanderposts!
        }
    }
    
    var arDelegate: ARPostDelegate!
    
    var addPostViewShown = false
    
    let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "wanderpost"
        //Make this more dynamic
        self.arDelegate = tabBarController?.viewControllers?.last as! ARViewController
        setupViewHierarchy()
        configureConstraints()
        configureTwicketSegmentControl()
        setupLocationManager()
        //        setupGestures()
        mapView.delegate = self
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
        
        CloudManager.shared.getWanderpostsForMap(location) { (posts, error) in
            if let error = error {
                print("Error fetching posts, \(error)")
            } else if let posts = posts {
                self.wanderposts = posts
                self.allWanderPosts = posts
                print("Post count..... \(self.wanderposts!.count)")
                self.reloadMapView()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    
    
    // MARK: - MKMapView
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
}

extension MapViewController: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        switch segmentIndex {
        case 0:
            print("Everyone")
            self.wanderposts = filterWanderPost(privacyLevel: .everyone)
        case 1:
            print("Friends")
            self.wanderposts = filterWanderPost(privacyLevel: .friends)
        case 2:
            print("Message")
            self.wanderposts = filterWanderPost(privacyLevel: .message)
        default:
            print("Can not make a decision")
        }
    }
    
    func filterWanderPost(privacyLevel: PrivacyLevel) -> [WanderPost] {
        switch privacyLevel {
        case PrivacyLevel.everyone:
            return (self.allWanderPosts.filter{$0.privacyLevel == .everyone})
        case PrivacyLevel.friends:
            return (self.allWanderPosts.filter{$0.privacyLevel == .friends})
        case PrivacyLevel.message:
            return (self.allWanderPosts.filter{$0.privacyLevel == .message})
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


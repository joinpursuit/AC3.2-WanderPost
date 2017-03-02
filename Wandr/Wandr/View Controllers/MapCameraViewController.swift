//
//  MapCameraViewController.swift
//  Wandr
//
//  Created by Ana Ma on 3/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit
import TwicketSegmentedControl

class MapCameraViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager : CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.requestWhenInUseAuthorization()
        locMan.distanceFilter = 1.0
        return locMan
    }()
    
    var addPostViewShown = false
    
    let segmentTitles = PrivacyLevelManager.shared.privacyLevelStringArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "wanderpost"
        
        self.view.backgroundColor = UIColor.yellow
        
        let frame = CGRect(x: 5, y: 75, width: view.frame.width - 10, height: 30)
        self.segmentedControl = TwicketSegmentedControl(frame: frame)
        self.segmentedControl.backgroundColor = UIColor.clear
        self.segmentedControl.setSegmentItems(segmentTitles)
        self.segmentedControl.delegate = self
        
        setupViewHierarchy()
        configureConstraints()
        //CloudManager.shared.getWanderpostsForMap(locationManager.location!, privacyLevel: .everyone)
        //        setupGestures()
    
        //http://stackoverflow.com/questions/27144508/apple-mapkit-3d-flyover
        //self.mapView.showsBuildings = true
        //let eiffelTowerCoordinates = CLLocationCoordinate2DMake(48.85815, 2.29452)
        //let eyeCoordinateEiffelTowerCoordinates = CLLocationCoordinate2DMake(48.85816, 2.29453)
        //let eyeCoordinateTimeSquare = CLLocationCoordinate2DMake(40.758898, 73.985130)
        //self.mapView.region = MKCoordinateRegionMakeWithDistance(eiffelTowerCoordinates, 1000, 100) // sets the visible region of the map
        
        //Create a 3D Camera
        //let mapCamera = MKMapCamera(lookingAtCenter: eiffelTowerCoordinates, fromDistance: 0.5, pitch: 0.0, heading: 0.0)
        
        //let mapCamera2 = MKMapCamera(lookingAtCenter: eiffelTowerCoordinates, fromEyeCoordinate: eyeCoordinateEiffelTowerCoordinates, eyeAltitude: 50)

        //let mapCamera3 = MKMapCamera(lookingAtCenter: timeSquareCoordinates, fromEyeCoordinate: eyeCoordinateTimeSquare, eyeAltitude: 50)
        //let timeSquareCoordinates = CLLocationCoordinate2DMake(73.985130, 40.758896)
        
        let timeSquareCoordinates = CLLocationCoordinate2DMake(40.74128, -73.985130)
        let mapCamera4 = MKMapCamera(lookingAtCenter: timeSquareCoordinates, fromDistance: 50, pitch: 85, heading: 0.0)
        mapView.region = MKCoordinateRegionMakeWithDistance(timeSquareCoordinates, 1000,100)
        mapView.mapType = .standard
        
        mapCamera4.altitude = 500 // example altitude
        mapView.camera = mapCamera4
    }
    
    // MARK: - Actions
    func addPostButtonPressed(_ sender: UIButton) {
        let postVC = PostViewController()
        postVC.location = locationManager.location
        self.navigationController?.present(postVC, animated: true, completion: nil)
    }
    
    // MARK: - Hierarchy
    private func setupViewHierarchy() {
        //Map Container View
        self.view.addSubview(self.mapContainerView)
        self.mapContainerView.addSubview(mapView)
        self.mapContainerView.addSubview(addPostButton)
        
        self.view.addSubview(addPostButton)
        self.view.addSubview(segmentedControl)
        
        locationManager.delegate = self
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
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        //mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "pitch" {
//            print(mapView.camera.pitch)
//        }
//    }
    
    //MARK: - Lazy Vars
    lazy var mapContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.mapType = MKMapType.standard
        mapView.showsBuildings = false
        //mapView.camera.addObserver(self, forKeyPath: "pitch", options: .new, context: nil)
        
        return mapView
    }()
    
    var camera: MKMapCamera!
    
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
        control.sliderBackgroundColor = UIColor.purple
        return control
    }()
    
}

extension MapCameraViewController: TwicketSegmentedControlDelegate {
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

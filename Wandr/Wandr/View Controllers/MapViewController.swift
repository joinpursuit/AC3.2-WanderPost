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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let locationManager : CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyBest
        locMan.requestWhenInUseAuthorization()
        locMan.distanceFilter = 1.0
        return locMan
    }()
    
    var addPostViewShown = false
    
    let segmentTitles = ["Internal", "Private", "Public"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellow

        setupViewHierarchy()
        configureConstraints()
        setupGestures()
    }
    
    // MARK: - Actions
    func togglePostView(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.up where self.addPostViewShown == false:
            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
             self.addPostViewShown = !addPostViewShown
        case UISwipeGestureRecognizerDirection.down where self.addPostViewShown == true:
            animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
             self.addPostViewShown = !addPostViewShown
        default:
            print("Not a recognized gesture")
        }
    }
    
    func animatePostView() {
        animateSettingsMenu(showPost: self.addPostViewShown, duration: 1.0, dampening: 0.5, springVelocity: 5)
        self.addPostViewShown = !addPostViewShown
    }
    
    private func animateSettingsMenu(showPost: Bool, duration: TimeInterval, dampening: CGFloat = 0.005, springVelocity: CGFloat = 0.005) {
        switch self.addPostViewShown {
        case true:
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: dampening, initialSpringVelocity: springVelocity, options: .curveEaseOut, animations: {
                
                self.dragUpContainerView.snp.remakeConstraints { (view) in
                    view.leading.equalToSuperview()
                    view.trailing.equalToSuperview()
                    view.height.equalToSuperview().multipliedBy(0.5)
                    view.width.equalToSuperview()
                }
                
                self.cheveronButton.snp.remakeConstraints { (button) in
                    button.top.equalToSuperview()
                    button.trailing.equalToSuperview().inset(16)
                }
                
                self.segmentedControlContainerView.snp.remakeConstraints { (view) in
                    view.top.equalTo(self.cheveronButton.snp.centerY)
                    view.leading.trailing.equalToSuperview()
                    view.height.equalToSuperview().multipliedBy(0.175)
                    view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
                }
                
                self.segmentedControl.snp.remakeConstraints { (control) in
                    control.top.leading.bottom.trailing.equalToSuperview()
                }
                
                self.postContainerView.snp.remakeConstraints { (view) in
                    view.top.equalTo(self.segmentedControlContainerView.snp.bottom)
                    view.leading.trailing.bottom.equalToSuperview()
                }
                
            }, completion: nil)
            
        case false:
           UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: dampening, initialSpringVelocity: springVelocity, options: .curveEaseOut, animations: {
            self.dragUpContainerView.snp.remakeConstraints({ (view) in
                view.leading.trailing.equalToSuperview()
                view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
                view.height.equalToSuperview().multipliedBy(0.5)
                view.width.equalToSuperview()
            })
            
            self.cheveronButton.snp.remakeConstraints { (button) in
                button.top.equalToSuperview()
                button.trailing.equalToSuperview().inset(16)
            }
            
            self.segmentedControlContainerView.snp.remakeConstraints({ (view) in
                view.top.equalTo(self.cheveronButton.snp.centerY)
                view.leading.trailing.equalToSuperview()
                view.height.equalToSuperview().multipliedBy(0.175)
            })
            
            self.segmentedControl.snp.remakeConstraints { (control) in
                control.top.leading.bottom.trailing.equalToSuperview()
            }
            
            self.postContainerView.snp.remakeConstraints { (view) in
                view.top.equalTo(self.segmentedControlContainerView.snp.bottom)
                view.leading.trailing.bottom.equalToSuperview()
            }
            
           }, completion: nil)
            
        default:
            print("I don't know what to do")
        }
    }
    
    // Mark: - Add Gestures
    private func setupGestures() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePostView))
        swipeUpGesture.direction = .up
        self.dragUpContainerView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(togglePostView))
        swipeDownGesture.direction = .down
         self.dragUpContainerView.addGestureRecognizer(swipeDownGesture)
    }
    
    // MARK: - Hierarchy
    private func setupViewHierarchy() {
        //Map Container View
        self.view.addSubview(self.mapContainerView)
        self.mapContainerView.addSubview(mapView)
        
        //Drag Up Container View
        self.view.addSubview(self.dragUpContainerView)
        self.dragUpContainerView.addSubview(segmentedControlContainerView)
        self.dragUpContainerView.addSubview(postContainerView)
        self.segmentedControlContainerView.addSubview(segmentedControl)
        self.dragUpContainerView.addSubview(cheveronButton)
        
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
        
        //Drag Up Container View
        dragUpContainerView.snp.makeConstraints { (view) in
            view.leading.equalToSuperview()
            view.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
            view.width.equalToSuperview()
        }
        
        cheveronButton.snp.makeConstraints { (button) in
            button.top.equalToSuperview()
            button.trailing.equalToSuperview().inset(16)
        }

        segmentedControlContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(self.cheveronButton.snp.centerY)
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.175)
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        segmentedControl.snp.makeConstraints { (control) in
            control.top.leading.bottom.trailing.equalToSuperview()
        }
        
        postContainerView.snp.makeConstraints { (view) in
            view.top.equalTo(segmentedControlContainerView.snp.bottom)
            view.leading.trailing.bottom.equalToSuperview()
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    //MARK: - Lazy Vars
    lazy var mapContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        return mapView
    }()
    
    lazy var dragUpContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cheveronButton: UIButton = {
       let button = UIButton()
        button.setTitle("Up", for: .normal)
        button.tintColor = UIColor.yellow
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(animatePostView), for: .touchDragInside)
        return button
    }()
    
    lazy var segmentedControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var segmentedControl: UIControl = {
        //let frame = CGRect(x: 5, y: 75, width: view.frame.width - 10, height: 40)
        let control = TwicketSegmentedControl(frame: CGRect.zero)
        control.delegate = self
        return control
    }()
    
    lazy var postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
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

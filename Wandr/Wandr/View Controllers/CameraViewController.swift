//
//  CameraViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CameraViewController: UIViewController {
    
    let myWanderPost = WanderPost(location: CLLocation(latitude: 40.7470, longitude: -73.9529), content: "I was in LIC Bar with the bucket brigade!" as AnyObject, contentType: .text, privacyLevel: .everyone)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "wanderpost"
        
        
        let arViewController = ARViewController()
        //1
        arViewController.dataSource = self
        //2
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        //3
        arViewController.setAnnotations([myWanderPost])
        
        self.present(arViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CameraViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension CameraViewController: AnnotationViewDelegate {
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


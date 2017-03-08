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

class DetailPostViewWithCommentsViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
        
        //TableViewSectionHeader
        let mapViewFrame = CGRect(x: 0, y: 0, width: commentTableView.frame.size.width, height: 275.0)
        self.mapHeaderView = MKMapView(frame: mapViewFrame)
        self.mapHeaderView.mapType = .standard
        self.mapHeaderView.isScrollEnabled = false
        self.mapHeaderView.isZoomEnabled = false
        self.mapHeaderView.showsBuildings = false
        self.mapHeaderView.showsUserLocation = true
        self.mapHeaderView.tintColor = StyleManager.shared.accent
        commentTableView.tableHeaderView = self.mapHeaderView
        self.mapHeaderView.delegate = self
        
        //TableViewCell
        self.commentTableView.register(ProfileViewViewControllerDetailFeedTableViewCell.self, forCellReuseIdentifier: ProfileViewViewControllerDetailFeedTableViewCell.identifier)

    }

    // MARK: - TableView Header And Footer Customizations
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let postHeaderFooterView = (self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: PostHeaderFooterView.identifier) as? PostHeaderFooterView)!
        self.postHeaderFooterView = postHeaderFooterView
        self.postHeaderFooterView.backgroundColor = UIColor.gray
        return postHeaderFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(commentTableView)
    }
    
    private func configureConstraints() {
        commentTableView.snp.makeConstraints { (tableView) in
            tableView.top.leading.trailing.bottom.equalToSuperview()
        }
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
}

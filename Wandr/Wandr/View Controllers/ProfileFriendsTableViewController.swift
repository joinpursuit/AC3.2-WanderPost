//
//  ProfileFriendsTableViewController.swift
//  Wandr
//
//  Created by Tom Seymour on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class ProfileFriendsTableViewController: UITableViewController, UISearchBarDelegate {
    
    var userFriends: [WanderUser]!
    
    var searchedFriends: [WanderUser]?

    var dummyData = [1,2,3,4,5,6,7,8]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = StyleManager.shared.accent
        self.navigationItem.title = "wanderpost"

        setUpSearchBar()        
        setUpTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        self.tableView.tableHeaderView = searchBar
        searchBar.delegate = self
    }
    
    func setUpTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150
        self.tableView.register(ProfileFriendTableViewCell.self, forCellReuseIdentifier: ProfileFriendTableViewCell.identifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummyData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileFriendTableViewCell.identifier, for: indexPath) as! ProfileFriendTableViewCell
        let user = self.dummyData[indexPath.row]
        cell.nameLabel.text = "\(user)"
        cell.addRemoveFriendButton.tag = indexPath.row
        cell.addRemoveFriendButton.addTarget(self, action: #selector(addOrRemoveFriend(_:)), for: UIControlEvents.touchUpInside)

        cell.nameLabel.text = "Tom"
        
        return cell
    }
    
    // MARK: - Button Action
    func addOrRemoveFriend(_ sender: UIButton) {
        let buttonTag = sender.tag
    }

}

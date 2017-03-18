//
//  ProfileFriendsTableViewController.swift
//  Wandr
//
//  Created by Tom Seymour on 3/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import CloudKit

enum FriendSearchDisplayType {
    case userFriends
    case searchedFriends
}

class ProfileFriendsTableViewController: UITableViewController, UISearchBarDelegate {
    
    var userFriends: [WanderUser]?
    
    var searchedFriends: [WanderUser]?
    
    var friendDisplayType: FriendSearchDisplayType = .searchedFriends
    
    var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.textLabel.text = "no users found"
        return view
    }()
    
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
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        searchBar.backgroundColor = StyleManager.shared.primary
        searchBar.barTintColor = StyleManager.shared.primary
        searchBar.autocapitalizationType = .none
        self.tableView.tableHeaderView = searchBar
        searchBar.delegate = self
    }
    
    func setUpTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150
        self.tableView.register(ProfileFriendTableViewCell.self, forCellReuseIdentifier: ProfileFriendTableViewCell.identifier)
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows: Int!
        switch friendDisplayType {
        case .userFriends:
            rows = userFriends?.count ?? 0
        case .searchedFriends:
            rows = searchedFriends?.count ?? 0
        }
        handleEmptyStateFor(empty: rows == 0)
        return rows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileFriendTableViewCell.identifier, for: indexPath) as! ProfileFriendTableViewCell
        var user: WanderUser!
        switch friendDisplayType {
        case .userFriends:
            user = userFriends![indexPath.row]
        case .searchedFriends:
            user = self.searchedFriends![indexPath.row]
        }
        cell.nameLabel.text = "\(user.username)"
        cell.profileImageView.image = UIImage(data: user.userImageData)
        cell.addRemoveFriendButton.tag = indexPath.row
        let areWeFriends = CloudManager.shared.currentUser!.friends.contains(user.id)
        let buttonTitle = areWeFriends ? "remove" : "add"
        cell.addRemoveFriendButton.setTitle(buttonTitle, for: .normal)
        cell.addRemoveFriendButton.addTarget(self, action: #selector(self.addOrRemoveFriend(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func handleEmptyStateFor(empty: Bool) {
        tableView.backgroundView = empty ? emptyStateView : nil
        tableView.isScrollEnabled = empty ? false : true
        tableView.separatorStyle = empty ? .none : .singleLine
    }

    
    // MARK: - Button Action
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        friendDisplayType = searchText.isEmpty ? .userFriends : .searchedFriends
        switch friendDisplayType {
        case .userFriends:
            tableView.reloadData()
            break
        case .searchedFriends:
            CloudManager.shared.search(for: searchText) { (wanderUsers, error) in
                if error != nil {
                    //error handle
                }
                
                if let validWanderUsers = wanderUsers {
                    self.searchedFriends = validWanderUsers
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func addOrRemoveFriend(_ sender: UIButton) {
        let buttonTag = sender.tag
        print(buttonTag)
        
        let userToAdd = self.searchedFriends![buttonTag]
        let areWeFriends = CloudManager.shared.currentUser!.friends.contains(userToAdd.id)
        
        if areWeFriends {
            CloudManager.shared.delete(friend: userToAdd.id) { (error) in
                print(error)
                DispatchQueue.main.async {
                    sender.setTitle("add", for: .normal)
                    
                }
            }
            
        } else {
            CloudManager.shared.add(friend: userToAdd.id) { (error) in
                print(error)
                DispatchQueue.main.async {
                    sender.setTitle("remove", for: .normal)
                }
            }
        }
        UIView.animate(withDuration: 0.1,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            sender.transform = CGAffineTransform.identity
                        }
        })
    }
}

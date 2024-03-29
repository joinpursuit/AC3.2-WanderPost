//
//  AppDelegate.swift
//  Wandr
//
//  Created by C4Q on 2/24/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications
import UserNotificationsUI



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //https://developer.apple.com/reference/foundation/nsusernotificationcenter
        //https://www.appcoda.com/push-notification-ios/
        
        //Set the Badge to 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = LoadingViewController()
        self.window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if error != nil {
                // Enable or disable features based on authorization.
                print(error!)
            }
        }
        application.registerForRemoteNotifications()
        return true
    }
    
    func setNavigationTheme() {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.barTintColor = StyleManager.shared.primary
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                       NSFontAttributeName: UIFont.Comfortaa.regular(size: 24)!]
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.tintColor = StyleManager.shared.accent
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = StyleManager.shared.primary
        
        let tabBarItemAppearance  = UITabBarItem.appearance()
        let normalAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                NSFontAttributeName: UIFont.Comfortaa.regular(size: 10)!]
        let selectedAttributes = [NSForegroundColorAttributeName: StyleManager.shared.accent,
                                  NSFontAttributeName: UIFont.Comfortaa.regular(size: 10)!]
        tabBarAppearance.isTranslucent = false
        tabBarItemAppearance.setTitleTextAttributes(normalAttributes, for: .normal)
        tabBarItemAppearance.setTitleTextAttributes(selectedAttributes, for: .selected)
        tabBarAppearance.tintColor = StyleManager.shared.accent
    }
    
    static func setUpAppNavigation() -> UIViewController {
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        let mapViewController = UINavigationController(rootViewController: MapViewController())
        let arViewController = UINavigationController(rootViewController: ARViewController())
        
        let profileIcon = UITabBarItem(title: "profile", image: UIImage(named: "profile_white"), selectedImage: nil)
        let mapIcon = UITabBarItem(title: "map", image: UIImage(named: "wire_icon"), selectedImage: nil)
        let arIcon = UITabBarItem(title: "a.r.", image: UIImage(named: "camera_white"), selectedImage: nil)
        
        profileViewController.tabBarItem = profileIcon
        mapViewController.tabBarItem = mapIcon
        arViewController.tabBarItem = arIcon
        
        let tabController = UITabBarController()
        tabController.viewControllers = [profileViewController, mapViewController, arViewController]
        tabController.tabBar.tintColor = StyleManager.shared.accent
        tabController.tabBar.unselectedItemTintColor = UIColor.white
        tabController.selectedIndex = 1
        
        return tabController
    }
    
    func setUpOnBoarding() -> UIViewController {
        let onBoardViewController = UINavigationController(rootViewController: OnBoardViewController())
        return onBoardViewController
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //MARK: - App Delegate Methods for Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dump("device token \(deviceToken)")
        //let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //let deviceTokenString = deviceToken.base64EncodedString()
        //print(deviceTokenString)
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("There's an \(error), usually of not able to register for remote notification because of the use of a simulator.")
    }
    
    
    //In here I should be able to change the username, im obviously getting the info. Maybe take that info and have it trigger a local notification instead of a real push notification?
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
                
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if cloudKitNotification.notificationType == .query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            if queryNotification.queryNotificationReason == .recordDeleted {
                // If the record has been deleted in CloudKit then delete the local copy here
            } else {
                // If the record has been created or changed, we fetch the data from CloudKit
                let database: CKDatabase
                if queryNotification.databaseScope == .public {
                    database = CKContainer.default().publicCloudDatabase
                } else {
                    database = CKContainer.default().privateCloudDatabase
                }
                database.fetch(withRecordID: queryNotification.recordID!, completionHandler: { (record: CKRecord?, error: Error?) -> Void in
                    guard error == nil else {
                        // Handle the error here
                        print("notification error: \(error!.localizedDescription)")
                        return
                    }
                    
                    if queryNotification.queryNotificationReason == .recordUpdated {
                        // Use the information in the record object to modify your local data
                    } else {
                        // Use the information in the record object to create a new local object
                    }
                })
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
}

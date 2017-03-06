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
        CloudManager.shared.getCurrentUser()
        setNavigationTheme()
        CloudManager.shared.getUserPostActivity { (string, error) in
            dump(string)
        }
        
        let rootVC = AppDelegate.setUpAppNavigation()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
        //https://developer.apple.com/reference/foundation/nsusernotificationcenter
        //https://www.appcoda.com/push-notification-ios/
        
        
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
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.backgroundColor = StyleManager.shared.primary
        navigationBarAppearace.barTintColor = StyleManager.shared.primary
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                      NSFontAttributeName: UIFont.Comfortaa.regular(size: 24)!]
        UIApplication.shared.statusBarStyle = .lightContent
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = StyleManager.shared.primary
        
        let tabBarItemAppearance  = UITabBarItem.appearance()
        let normalAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                NSFontAttributeName: UIFont.Comfortaa.regular(size: 20)!]
        let selectedAttributes = [NSForegroundColorAttributeName: StyleManager.shared.accent,
                                  NSFontAttributeName: UIFont.Comfortaa.regular(size: 20)!]
        tabBarItemAppearance.setTitleTextAttributes(normalAttributes, for: .normal)
        tabBarItemAppearance.setTitleTextAttributes(selectedAttributes, for: .selected)
        tabBarAppearance.tintColor = StyleManager.shared.accent
    }
    
    static func setUpAppNavigation() -> UIViewController {
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        let mapViewController = UINavigationController(rootViewController: MapViewController())
        let arViewController = ARViewController()
        
        let profileIcon = UITabBarItem(title: "profile", image: nil, selectedImage: nil)
        let mapIcon = UITabBarItem(title: "map", image: nil, selectedImage: nil)
        let arIcon = UITabBarItem(title: "AR", image: nil, selectedImage: nil)        
        
        //1
        arViewController.dataSource = mapViewController.viewControllers.first! as! MapViewController
        //2
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        //3
        arViewController.setAnnotations([])
        
        
        profileViewController.tabBarItem = profileIcon
        mapViewController.tabBarItem = mapIcon
        //onBoardViewController.tabBarItem = onBoardIcon
        arViewController.tabBarItem = arIcon
        
        let tabController = UITabBarController()
        tabController.viewControllers = [profileViewController, mapViewController, arViewController]
        tabController.tabBar.tintColor = StyleManager.shared.accent
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("user info \(userInfo)")
    }
    
}


/*
 
 //        let locationTrigger = UNLocationNotificationTrigger(region: <#T##CLRegion#>, repeats: <#T##Bool#>)
 //
 //        let notificationRequest = UNNotificationRequest.init(identifier: "newPosts", content: <#T##UNNotificationContent#>, trigger: <#T##UNNotificationTrigger?#>)
 //
 //        UNUserNotificationCenter.current().add(<#T##request: UNNotificationRequest##UNNotificationRequest#>, withCompletionHandler: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
 
 //        let authorizationOptions: UNAuthorizationOptions = [UNAuthorizationOptions.alert, UNAuthorizationOptions.badge, UNAuthorizationOptions.sound]
 //        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions) { (success: Bool?, error: Error?) in
 //            // Enable or disable features based on authorization.
 //        }
 //
 //        UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
 //
 //            switch settings.soundSetting{
 //            case .enabled:
 //
 //                print("enabled sound setting")
 //
 //            case .disabled:
 //
 //                print("setting has been disabled")
 //
 //            case .notSupported:
 //                print("something vital went wrong here")
 //            }
 //        }
 //        application.registerForRemoteNotifications()
 
 
 //We can use UNLocationNotificationTrigger - Triggers the delivery of a notification when the user reaches the specified geographic location.
 
 //If we use EventKit we can implement UNCalendarNotificationTrigger - Triggers a notification at the specified date and time.
 
 //If we have media in our notification, we can use UNNotificationAttachment - Manages media content associated with a notification.
 */

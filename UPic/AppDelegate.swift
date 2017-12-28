//
//  AppDelegate.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let categoryVC = UINavigationController(rootViewController: CategoryViewController())
        //let uploadVC = UploadViewController()
        let uploadVC = UINavigationController(rootViewController: UploadViewController())
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        
        let tabs = UITabBarController()
        tabs.viewControllers = [categoryVC, uploadVC, profileVC]
        
        
        
        let categoryTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "gallery_icon"), selectedImage: #imageLiteral(resourceName: "gallery_icon"))
        categoryTab.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
        categoryVC.tabBarItem = categoryTab
        
        let uploadTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "camera_icon"), selectedImage: #imageLiteral(resourceName: "camera_icon"))
        uploadTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        uploadVC.tabBarItem = uploadTab
        
        let profileTab = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "user_icon"), selectedImage: #imageLiteral(resourceName: "user_icon"))
        profileTab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        profileVC.tabBarItem = profileTab
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 20.0),
                                                            NSForegroundColorAttributeName : UIColor.white]
        
        tabs.tabBar.backgroundColor = ColorPalette.lightPrimaryColor
        tabs.tabBar.barTintColor = ColorPalette.lightPrimaryColor
        tabs.tabBar.tintColor = ColorPalette.accentColor
        
        tabs.selectedIndex = 2
        
        self.window?.rootViewController = tabs
        
        self.window?.makeKeyAndVisible()
        
        if FIRAuth.auth()?.currentUser != nil {
        do {
                try FIRAuth.auth()?.signOut()
            }
            catch {
                print(error)
            }
        }
       
            do {
                FIRAuth.auth()?.signInAnonymously() { (user, error) in
                    _ = user!.isAnonymous  // true
                    _ = user!.uid
                }
            }
        
        
        return true
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
    
    
}


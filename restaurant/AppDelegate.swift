//
//  AppDelegate.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var orderTabBarItem: UITabBarItem!
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let temporaryDirectory = NSTemporaryDirectory()
        let urlCache = URLCache(memoryCapacity: 25_000_000, diskCapacity: 50_000_000, diskPath: temporaryDirectory)
        URLCache.shared = urlCache
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOrderTabBarBadge), name: MenuService.orderUpdatedNotification, object: nil)
        
        self.orderTabBarItem = (self.window?.rootViewController as! UITabBarController).viewControllers![1].tabBarItem

        updateOrderTabBarBadge()
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MenuService.shared.loadOrder()
        MenuService.shared.loadItems()
        
        MenuService.shared.loadRemoteData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        MenuService.shared.saveOrder()
        MenuService.shared.saveItems()
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
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

    @objc func updateOrderTabBarBadge() {
        switch MenuService.shared.order.items.count {
        case 0:
            self.orderTabBarItem.badgeValue = nil
        case let count:
            self.orderTabBarItem.badgeValue = "\(count)"
        }
    }
}


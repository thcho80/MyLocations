//
//  AppDelegate.swift
//  MyLocations
//
//  Created by human on 2018. 12. 7..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let currentViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentViewController.managedObjectContext = managedObjectContext
            
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

    //MARK - Core Data

    lazy var managedObjectContext : NSManagedObjectContext = {
       
        guard let modelURL = Bundle.main.url(forResource: "MyLocation", withExtension: "momd") else { fatalError("Could not find data model in app bundle") }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Error initializing model from : \(modelURL)")}
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0]
        
        let storeURL = documentDirectory.appendingPathComponent("DataStore.sqlite")
        
        var error:NSError?
        
        do {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            let context = NSManagedObjectContext()
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {fatalError("Error adding persistent store at \(storeURL): \(error)") }
        
    }()
}


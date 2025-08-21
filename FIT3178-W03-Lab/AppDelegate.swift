//
//  AppDelegate.swift
//  FIT3178-W03-Lab
//
//  Created by Viet Tran on 13/8/2025.
//

import UIKit

//It is created when the application starts, continues to exist in the
//background and only disappears when the application is closed or killed. As such, it is
//the perfect place to store the reference to the Core Data controller.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var databaseController: DatabaseProtocol?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        Our database will always be available while the app is running. (We have defined the databaseController property as conforming to DatabaseProtocol, rather than being a  specific class. We will replace it with a different class in Lab 6.
        databaseController = CoreDataController()
        return true
        
        
//        Due to the decoupling of the database and view controllers, the changes to existing
//        code were minimal. With a change to a different database the only code that would
//        need to be tweaked is the AppDelegate class, the Database Controller, plus the
//        onTeamChange and onAllHeroesChange methods
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


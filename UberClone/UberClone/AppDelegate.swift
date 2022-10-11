//
//  AppDelegate.swift
//  UberClone
//
//  Created by RadCns_KIM_TAEWON on 2022/10/06.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = HomeController()
        
        return true
    }



}


//
//  AppDelegate.swift
//  GMSMap Draw Polyline
//
//  Created by Giri on 25/10/21.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let googlemapToken = "" //"YOUR_API_KEY"
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googlemapToken)
        return true
    }
    
}


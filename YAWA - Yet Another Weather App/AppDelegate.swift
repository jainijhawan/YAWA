//
//  AppDelegate.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 10/07/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit
import SwiftCSV
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window:UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
    // Override point for customization after application launch.
    return true
  }
}


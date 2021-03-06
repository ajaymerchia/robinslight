//
//  AppDelegate.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/25/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import IQKeyboardManager
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	static var isMac: Bool {
		#if targetEnvironment(macCatalyst)
				return true
		#else
				return false
		#endif
		
	}
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		Design.configDesign()
		
		IQKeyboardManager.shared().isEnabled = true
		
		print(Date().timeIntervalSince1970)
		FirebaseApp.configure()
		
		return true
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


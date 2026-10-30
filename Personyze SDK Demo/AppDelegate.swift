//
//  AppDelegate.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/7/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import Personyze
import UIKit
import UserNotifications

/// How the demo sets the SDK up.
enum Demo
{	/// Where the key the user typed is kept (`MYTextField` saves it). A real app has its key in its code.
	static let apiKeyStorage = "API Key"

	static var storedKey: String?
	{	UserDefaults.standard.string(forKey: apiKeyStorage).flatMap { $0.count == 40 ? $0 : nil }
	}

	/// Again with the same key keeps the client; another key replaces it.
	static func initialize(apiKey: String)
	{	Personyze.initialize(
			PersonyzeConfig(apiKey: apiKey)
			{	$0.notifications = true
				$0.onError = { error, context in
					print("Personyze, \(context.operation): \(error.message)")
				}
			}
		)
	}

	/// Notifications of "Web Push Send" campaigns appear only once the user allows them.
	static func askForNotifications()
	{	UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
		}
	}
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
	{	// As the app starts: a launch for background refresh finds the key only here.
		if let key = Demo.storedKey
		{	Demo.initialize(apiKey: key)
		}
		UNUserNotificationCenter.current().delegate = self
		return true
	}

	/// A notification arriving while the demo is in front is shown too.
	nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
	{	[.banner, .list, .sound]
	}

	/// A tap on a Personyze notification, or on one of its buttons, opens where it leads.
	nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async
	{	if Personyze.handleNotificationResponse(response)
		{	return
		}
		// The app's own notifications would be handled here.
	}
}

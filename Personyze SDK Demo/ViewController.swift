//
//  ViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/7/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit

/// The first screen: the API key.
class ViewController: UIViewController
{	@IBOutlet weak var inputKey: MYTextField!
	@IBOutlet weak var labelError: UILabel!

	override func viewDidLoad()
	{	super.viewDidLoad()
		inputKey.setStorageKey(Demo.apiKeyStorage)
		inputKey.setDidEndEditing(textFieldDidEndEditing)
	}

	func textFieldDidEndEditing(textField: UITextField)
	{	if textField == inputKey && initTracker()
		{	performSegue(withIdentifier: "toDemo", sender: self)
		}
	}

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
	{	identifier != "toDemo" || initTracker()
	}

	func initTracker() -> Bool
	{	let key = (inputKey.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		if key.count != 40
		{	labelError.text = "API key must be 40 characters"
			return false
		}
		labelError.text = ""
		Demo.initialize(apiKey: key)
		Demo.askForNotifications()
		return true
	}
}

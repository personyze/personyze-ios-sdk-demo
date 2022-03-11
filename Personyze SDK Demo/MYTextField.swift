//
//  MYTextField.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/7/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit

class MYTextField : UITextField, UITextFieldDelegate
{	private var storageKey: String?
	private var didEndEditing: ((UITextField) -> Void)?

	required init?(coder aDecoder: NSCoder)
	{	super.init(coder: aDecoder)
	}

	func setStorageKey(_ storageKey: String?)
	{	self.storageKey = storageKey
		if let storageKey = self.storageKey
		{	if let value = UserDefaults.standard.string(forKey: storageKey)
			{	text = value
			}
		}
		delegate = self
	}

	func setDidEndEditing(_ didEndEditing: ((UITextField) -> Void)?)
	{	self.didEndEditing = didEndEditing
		delegate = self
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{	resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField)
	{	if let storageKey = self.storageKey
		{	UserDefaults.standard.set(text, forKey: storageKey)
		}
		if let didEndEditing = didEndEditing
		{	didEndEditing(self)
		}
	}
}

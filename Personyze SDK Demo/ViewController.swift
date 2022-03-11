//
//  ViewController.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/7/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{   @IBOutlet weak var inputKey: MYTextField!
    @IBOutlet weak var labelError: UILabel!

    override func viewDidLoad()
    {   super.viewDidLoad()

		inputKey.setStorageKey("API Key")
		inputKey.setDidEndEditing(textFieldDidEndEditing)
    }

	func textFieldDidEndEditing(textField: UITextField)
	{	if textField == inputKey && initTracker()
		{	performSegue(withIdentifier: "toDemo", sender: self)
		}
	}
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {   return identifier != "toDemo" || initTracker()
    }

    func initTracker() -> Bool
    {	if (inputKey.text ?? "").count != 40
        {   labelError.text = "API key must be 40 characters"
            return false
        }
        else
        {   labelError.text = ""
            PersonyzeTracker.inst.initialize(apiKey: inputKey.text ?? "")
            return true
        }
    }
}



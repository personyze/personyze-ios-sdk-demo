//
//  MYPickerView.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/8/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit

class MYPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource
{	private var data: [String] = []
    private var onChange: ((Int) -> Void)?

    func setOptions(_ newData: [String])
    {	data = newData
		delegate = self
		reloadAllComponents()
    }

    func setOnChange(_ onChange: ((Int) -> Void)?)
    {   self.onChange = onChange
		delegate = self
    }

	func getValue() -> Int
	{	return selectedRow(inComponent: 0)
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int
	{	return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{	return data.count
	}

	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
	{	let label = view as? UILabel ?? UILabel()
		label.font = UIFont (name: "System", size: 14)
		label.text = data[row]
		label.textAlignment = .natural
		return label
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{   if let onChange = onChange
        {   onChange(getValue())
        }
	}
}

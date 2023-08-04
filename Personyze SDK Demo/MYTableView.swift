//
//  MYTableView.swift
//  Personyze SDK Demo
//
//  Created by Jeremiah Shaulov on 3/8/19.
//  Copyright © 2019 Personyze. All rights reserved.
//

import UIKit

class MYTableView: UITableView, UITableViewDataSource, UITableViewDelegate
{	private var rows: [(String, Bool)] = []
	private var onSelect: ((Int) -> Void)?

    func setRows(strings: [String])
    {   setRows(rows: strings.map() {($0, true)})
    }

    func setOnSelect(_ onSelect: ((Int) -> Void)?)
    {   self.onSelect = onSelect
    }

    func setRows(rows: [(String, Bool)])
    {   self.rows = rows
        dataSource = self
        delegate = self
        reloadData()
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{   return rows.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{   let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = rows[indexPath.row].0
        cell.detailTextLabel?.isHidden = !rows[indexPath.row].1
		return cell
	}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{   if let onSelect = onSelect
		{	onSelect(indexPath.row)
		}
	}
}

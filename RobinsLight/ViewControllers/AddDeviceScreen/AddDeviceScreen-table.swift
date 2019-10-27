//
//  AddDeviceScreen-table.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Protocol Conformance for AddDeviceScreen_table

import Foundation
import UIKit
import ARMDevSuite

extension AddDeviceScreen: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let view = UIView()
		view.backgroundColor = UIColor.robinPrimary.withAlphaComponent(1)
		let label = UILabel(); view.addSubview(label)
			label.translatesAutoresizingMaskIntoConstraints = false
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding).isActive = true
		
		label.text = ["New Devices", "Old Assets"][section]
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
		
		
		return view
	
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return uniques.count > 0 ? uniques.count : 1
		} else {
			return self.existingDevices.count > 0 ? existingDevices.count : 1
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "deviceCell")
		if indexPath.section == 0 {
			if uniques.count > 0 {
				let device = self.uniques[indexPath.row]
				cell.textLabel?.text = device.id
				cell.detailTextLabel?.text = device.commonName
			} else {
				cell.textLabel?.text = "No devices detected!"
				cell.detailTextLabel?.text = "Press the refresh button to try again."
			}
		} else {
			if existingDevices.count > 0 {
				let device = self.existingDevices[indexPath.row]
				cell.textLabel?.text = device.id
				cell.detailTextLabel?.text = device.commonName
			} else {
				cell.textLabel?.text = "No existing devices!"
				cell.detailTextLabel?.text = "Press the refresh button to start and make a new connection."
			}
		}
		
		cell.textLabel?.textColor = .robinBlue
		cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		cell.detailTextLabel?.textColor  = .robinBlack
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10, weight: .light)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		if indexPath.section == 0 {
			if self.uniques.count > 0 {
				let device = self.uniques[indexPath.row]
				self.setupNewDevice(device)
			} else {
				self.searchForBluetoothReceivers()
			}
		} else {
			if self.existingDevices.count > 0 {
				let device = self.existingDevices[indexPath.row]
				self.addExistingDeviceToRoutine(device)
			} else {
				self.searchForBluetoothReceivers()
			}
			
		}
	}
	
	
	
	
}

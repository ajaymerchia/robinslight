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
		
		label.text = ["Old Assets", "New Devices"][section]
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
		
		
		return view
		
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return self.existingDevices.count > 0 ? existingDevices.count : 1
		} else {
			return uniques.count > 0 ? uniques.count : 1
		}
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "deviceCell")
		cell.textLabel?.textColor = .robinBlue
		cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
		cell.detailTextLabel?.textColor  = .robinBlack
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10, weight: .light)
		
		
		if indexPath.section == 0 {
			if existingDevices.count > 0 {
				let device = self.existingDevices[indexPath.row]
				cell.textLabel?.text = device.commonName
				cell.detailTextLabel?.text = device.id
				
				if !(delegate?.addDeviceScreen(self, allowDeviceSelectionFor: device) ?? true) {
					cell.textLabel?.textColor = .robinGray
					cell.textLabel?.text = "\(device.commonName) (Already in routine)"
				}
				
			} else {
				cell.textLabel?.text = "No existing devices!"
				cell.detailTextLabel?.text = "Press the refresh button to start and make a new connection."
			}
		} else {
			if uniques.count > 0 {
				let device = self.uniques[indexPath.row]
				cell.textLabel?.text = device.commonName
				cell.detailTextLabel?.text = device.id
				cell.backgroundColor = device.isRelevant ? (UIColor.robinLavender).withAlphaComponent(0.3) : .clear
			} else {
				cell.textLabel?.text = "No devices detected!"
				cell.detailTextLabel?.text = "Press the refresh button to try again."
			}
		}
		
		
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.section == 0 {
			if existingDevices.count > 0 {
				let device = self.existingDevices[indexPath.row]
				if !(delegate?.addDeviceScreen(self, allowDeviceSelectionFor: device) ?? true) {
							return nil
				}
			}
		}
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		if indexPath.section == 0 {
			if self.existingDevices.count > 0 {
				let device = self.existingDevices[indexPath.row]
				self.addExistingDeviceToRoutine(device)
			} else {
				self.searchForBluetoothReceivers()
			}
		} else {
			if self.uniques.count > 0 {
				let device = self.uniques[indexPath.row]
				self.setupNewDevice(device)
			} else {
				self.searchForBluetoothReceivers()
			}
		}
	}
	
	
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		if indexPath.section == 0 {
			return .delete
		}
		return .none
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//		BluetoothManager.shared.delegate = nil
		if editingStyle == .delete {
			
			let targeted = self.existingDevices.remove(at: indexPath.row)
			RobinCache.records(for: Device.self).delete(id: targeted.id) { (err) in
				guard err == nil else {
					self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
					return
				}
//				if tableView.numberOfRows(inSection: 0) == 1 {
//					tableView.reloadRows(at: [indexPath], with: .fade)
//				} else {
//					tableView.deleteRows(at: [indexPath], with: .fade)
//				}
				tableView.reloadData()
				
//				BluetoothManager.shared.delegate = self

			}
			
		}
	}
	
	
}

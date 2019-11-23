//
//  AddDeviceScreen-logic.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite
import CoreBluetooth

extension AddDeviceScreen: PiBluetoothAPIDelegate {
	func piAPI(piAPI: PiBluetoothAPI, disconnectedFrom device: Device, explanation: String?) {
		self.alerts.displayAlert(titled: "FYI", withDetail: explanation ?? "\(device.commonName) has disconnected.", completion: nil)
	}

	
	@objc func searchForBluetoothReceivers() {
		PiBluetoothAPI.shared.findDevices { (device, err) in
			guard let device = device, err == nil else { return }
			self.scanResults[device.id] = device
			self.table.reloadSections(IndexSet(integer: 1), with: .automatic)
		}
	}
	
	func setupNewDevice(_ device: Device) {
		PiBluetoothAPI.shared.stopSearching()
		self.alerts.getTextInput(withTitle: "What would you like to name this device?", andHelp: nil, andPlaceholder: device.commonName, placeholderAsText: true, completion: { (assignedName) in
			
			self.alerts.startProgressHud(withTitle: "Pairing...")
			device.commonName = assignedName
			self.pendingDevice = device
			// Connect to Device
			PiBluetoothAPI.shared.connectTo(device: device) { (err) in
				guard err == nil else {
					self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
					self.pendingDevice = nil
					return
				}
				print("Connected to \(device.commonName)")
				self.alerts.changeHUD(toTitle: "Validating...", andDetail: nil)
				
				
				// Validate Device
				PiBluetoothAPI.shared.validateCompatibility(for: device) { (err) in
					guard err == nil else {
						self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
						self.pendingDevice = nil
						return
					}
					print("Validated \(device.commonName)")
					
					// Store Device
					RobinCache.records(for: Device.self).store(device) { (err) in
						guard err == nil else {
							self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
							return
						}
						self.alerts.triggerHudSuccess(withHeader: "Device Added!", andDetail: nil) {
							self.addExistingDeviceToRoutine(device)
						}

					}
					
				}
				
			}
			
		})
		
	}
	
	/// Load existing Devices
	func getData() {
		DataStack.list(type: Device.self) { (deviceIDs, err) in
			guard let ids = deviceIDs else {
				self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
				return
			}
			DispatchGroup(vals: ids, forEach: { (id, g) in
				RobinCache.records(for: Device.self).get(id: id) { (r, err) in
					if let r = r {
						self.existingDevices.append(r)
						print(r.prettyJSONRepr)
					} else {
						print(err)
					}
					g.leave()
				}
			}).notify(queue: .main) {
				self.table.reloadData()
			}
		}
	}
	
	func addExistingDeviceToRoutine(_ device: Device) {
		self.delegate?.addDeviceScreen(self, didSelect: device)
		self.dismiss(animated: true, completion: nil)
	}


}

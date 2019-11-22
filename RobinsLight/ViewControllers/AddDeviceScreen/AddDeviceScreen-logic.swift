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

extension AddDeviceScreen: BluetoothManagerDelegate {
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didDiscover peripheral: CBNamedPeripheral) {
		self.scanResults[peripheral.id] = peripheral
		self.table.reloadSections(IndexSet(integer: 1), with: .automatic)
	}
	
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didConnectTo peripheral: CBPeripheral) {
		guard self.pendingDevice?.id == peripheral.identifier.uuidString else {
			self.alerts.triggerHudFailure(withHeader: "Pairing Cancelled", andDetail: nil)
			return
		}
		self.alerts.changeHUD(toTitle: "Validating Compatibility", andDetail: nil)
		BluetoothManager.shared.validate(peripheral: peripheral)
		
		return
	}
	
	func manager(_ bluetoothManagerDelegate: BluetoothManager, canWriteTo peripheral: CBPeripheral, onChannel channel: CBCharacteristic) {
		// store the device in FileSys
		guard let pDevice = self.pendingDevice else {
			// ignore this run -- a previous delegate has already responded
			return
		}
		guard peripheral.identifier.uuidString == self.pendingDevice?.id else {
			self.alerts.triggerHudFailure(withHeader: "Device Not Compatible", andDetail: "Does not support Read/Write")
			return
		}
		
		
		RobinCache.records(for: Device.self).store(pDevice) { (err) in
			guard err == nil else {
				self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				return
			}
			self.alerts.triggerHudSuccess(withHeader: "Device Added!", andDetail: nil) {
				self.addExistingDeviceToRoutine(pDevice)
			}
			
		}
		
	}
	
	@objc func searchForBluetoothReceivers() {
		BluetoothManager.shared.delegate = self
		BluetoothManager.shared.findPeripherals()
	}
	
	
	
	
	func setupNewDevice(_ device: CBNamedPeripheral) {
		self.alerts.getTextInput(withTitle: "What would you like to name this device?", andHelp: nil, andPlaceholder: device.name, placeholderAsText: true, completion: { (assignedName) in
			
			self.alerts.startProgressHud(withTitle: "Pairing...")
			self.pendingDevice = Device(id: device.id, commonName: assignedName)
			
			// pair with the device
			BluetoothManager.shared.connectTo(peripheral: device.peripheral)
			
		})
		
		
//		Timer.fire(after: 1) {
//			self.alerts.changeHUD(toTitle: "Setting up...", andDetail: nil)
//			Timer.fire(after: 1) {
//				self.alerts.triggerHudSuccess(withHeader: "Device Added!", andDetail: nil, onComplete: {
////					self.addExistingDeviceToRoutine(device)
//				})
//
//			}
////			RobinCache.records(for: Device.self).store(device) { (err) in
////
////			}
//
//		}
		
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

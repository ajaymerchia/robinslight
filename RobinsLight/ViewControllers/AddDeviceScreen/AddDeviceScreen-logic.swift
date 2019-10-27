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

extension AddDeviceScreen {
	@objc func searchForBluetoothReceivers() {
		self.alerts.startProgressHud(withTitle: "Searching for Bluetooth Devices...", withDetail: "Make sure the AT-09's are powered on and in pairing mode")
		
		Timer.fire(after: 2) {
			self.alerts.dismissHUD()
			self.scanResults = Device.sampleDevices
			self.table.reloadData()
		}
	}
	
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
	
	func setupNewDevice(_ device: Device) {
		self.alerts.startProgressHud(withTitle: "Pairing...")
		Timer.fire(after: 1) {
			self.alerts.changeHUD(toTitle: "Setting up...", andDetail: nil)
			RobinCache.records(for: Device.self).store(device) { (err) in
				Timer.fire(after: 1) {
					self.alerts.triggerHudSuccess(withHeader: "Device Added!", andDetail: nil, onComplete: {
						self.addExistingDeviceToRoutine(device)
					})
					
				}
			}
			
		}
		
	}
	
	func addExistingDeviceToRoutine(_ device: Device) {
		self.delegate?.addDeviceScreen(self, didSend: device)
		self.dismiss(animated: true, completion: nil)
	}


}

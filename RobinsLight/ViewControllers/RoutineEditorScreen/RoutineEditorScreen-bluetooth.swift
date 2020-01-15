//
//  RoutineEditorScreen-bluetooth.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 11/8/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen: PiBluetoothAPIDelegate {
	func piAPI(piAPI: PiBluetoothAPI, disconnectedFrom device: Device, explanation: String?) {
		self.alerts.displayAlert(titled: "FYI", withDetail: explanation ?? "\(device.commonName) has disconnected.", completion: nil)
	}
	
	func showOptions(forDevice device: Device) {
		var configs = [
			ActionConfig(title: "Check Connection", style: .default, callback: {
				self.checkConnection(forDevice: device)
			}),
			ActionConfig(title: "Copy Device ID", style: .default, callback: {
				UIPasteboard.general.string = device.id
			}),
			ActionConfig(title: "Upload Routine", style: .default, callback: {
				self.uploadRoutine(forDevice: device)
			}),
			ActionConfig(title: "Test Run on Device", style: .default, callback: {
				self.playRoutine(forDevice: device)
				self.startRunTime()
			})
		]
		
		if !device.isReal {
			configs.append(ActionConfig(title: "Attach to Pi", style: .default, callback: {
				self.attachPiToFake(forDevice: device)
				return
			}))
		}
		
		
		
		self.alerts.showActionSheet(withTitle: device.commonName, andDetail: device.id, configs: configs)
		
		
		
	}
	
	func attachPiToFake(forDevice device: Device) {
		self.addDelegatePurpose = .attach(device)
		self.performSegue(withIdentifier: "editor2addDevice", sender: nil)
	}
	
	func playRoutine(forDevice device: Device, refDate date: Date = Date()) {
		//		self.alerts.getTextInput(withTitle: "Manual delay?", andHelp: nil, andPlaceholder: "ms", completion: { (str) in
		//			PiBluetoothAPI.shared.write(data: "\(PlayerCommand.start.rawValue):\(Date().timeIntervalSince1970)", device: device, service: .routine, channel: .player) { (err) in
		//				if let delay = TimeInterval(str) {
		//					Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { (_) in
		//						self.startRunTime()
		//					}
		//				} else {
		//					self.startRunTime()
		//
		//				}
		//			}
		//
		//		})
		PiBluetoothAPI.shared.write(data: "\(PlayerCommand.start.rawValue):\(date.timeIntervalSince1970)", device: device, service: .routine, channel: .player) { (err) in
			self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
		}
	}
	func stopRoutine(forDevice device: Device) {
		PiBluetoothAPI.shared.write(data: "\(PlayerCommand.stop.rawValue)", device: device, service: .routine, channel: .player) { (err) in
			self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
		}
	}
	func uploadRoutine(forDevice device: Device) {
		self.alerts.startProgressHud(withTitle: "Uploading Routine")
		TrackExportManager.exportTrackToString(for: device, in: self.routine) { (track, err) in
			guard let track = track, err == nil else {
				self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				return
			}
			
			PiBluetoothAPI.shared.write(data: track, device: device, service: .routine, channel: .routineReceive) { (err) in
				if err == nil {
					self.alerts.triggerHudSuccess(withHeader: "Success", andDetail: "File sent to device.")
				} else {
					self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				}
			}
			
		}
	}
	func checkConnection(forDevice device: Device) {
		self.alerts.startProgressHud(withTitle: "Verifying")
		PiBluetoothAPI.shared.validateCompatibility(for: device) { (err) in
			guard err == nil else {
				self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				return
				
			}
			self.alerts.triggerHudSuccess(withHeader: "Success", andDetail: "Device connected and validated")
		}
	}
	
}

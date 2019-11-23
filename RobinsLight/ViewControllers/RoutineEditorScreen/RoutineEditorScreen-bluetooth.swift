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
		self.alerts.showActionSheet(withTitle: device.commonName, andDetail: device.id, configs: [
			ActionConfig(title: "Check Connection", style: .default, callback: {
				self.checkConnection(forDevice: device)
			}),
			ActionConfig(title: "Copy Device ID", style: .default, callback: {
				UIPasteboard.general.string = device.id
			}),
			ActionConfig(title: "Upload Routine", style: .default, callback: {
				self.uploadRoutine(forDevice: device)
			})
			
		])
		
		
		
	}
	
	func uploadRoutine(forDevice device: Device) {
		self.alerts.startProgressHud(withTitle: "Uploading Routine")
		TrackExportManager.exportTrackToString(for: device, in: self.routine) { (track, err) in
			guard let track = track, err == nil else {
				self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				return
			}
			
			PiBluetoothAPI.shared.write(data: track, device: device, service: .pingpong, channel: .pingpong) { (err) in
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

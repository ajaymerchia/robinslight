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
			
			var data = track
			
//			
//			var cnt = 10
//			
//			Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (t) in
//				guard cnt < 200 else {
//					t.invalidate()
//					return
//				}
//				print("Attempting \(cnt) characters")
//				
//				
//				let countStr = "\(cnt)_"
//				let testStr = "\(countStr)\(data.prefix(cnt-countStr.count))"
//				BluetoothManager.shared.send(data: testStr, to: device, completion: nil)
//
//				cnt += 5
//			}

			
			BluetoothLib.shared.send(data: data, to: device) { (err) in
				guard err == nil else {
					self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
					return
				}
				
				
				self.alerts.triggerHudSuccess(withHeader: "Success", andDetail: "Track uploaded", onComplete: {
					
				})
				Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (_) in
					self.startRunTime()
				}
				
			}
			
		}
	}
	
	func checkConnection(forDevice device: Device) {
		self.alerts.startProgressHud(withTitle: "Verifying")
		BluetoothLib.shared.validateConnection(toDevice: device) { (err) in
			guard err == nil else {
				self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
				return
				
			}
			self.alerts.triggerHudSuccess(withHeader: "Success", andDetail: "Able to connect to device")

		}
	}
	
}

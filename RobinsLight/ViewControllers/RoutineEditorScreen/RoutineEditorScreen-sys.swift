//
//  RoutineEditorScreen-sys.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// System - Segues, Observers, Managers, and UI Event Triggers

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen: AddDeviceScreenDelegate {
	func addDeviceScreen(_ addDeviceScreen: AddDeviceScreen, allowDeviceSelectionFor device: Device) -> Bool {
		return !self.routine.deviceIDs.contains(device.id)
	}
	
	func addDeviceScreen(_ addDeviceScreen: AddDeviceScreen, didSelect device: Device) {
		
		switch self.addDelegatePurpose {
		case .new:
			self.routine.deviceIDs.append(device.id)
			self.routine.deviceTracks[device.id] = []
			
			RobinCache.records(for: Routine.self).store(self.routine) { (_) in
				self.table.reloadSections(IndexSet(integer: 1), with: .fade)
			}
		case .attach(let oldDevice):
			guard let oldIdx = self.routine.deviceIDs.firstIndex(of: oldDevice.id) else {
				self.alerts.displayAlert(titled: .err, withDetail: "Unable to add device. Old copy no longer exists in this routine", completion: nil)
				return
			}
			
			device.commonName = oldDevice.commonName
			
			self.routine.deviceIDs.remove(at: oldIdx)
			self.routine.deviceIDs.insert(device.id, at: oldIdx)
			
			RobinCache.records(for: Routine.self).store(self.routine) { (err) in
				RobinCache.records(for: Device.self).store(device) { (err2) in
					self.table.reloadSections(IndexSet(integer: 1), with: .fade)

					guard err == nil, err2 == nil else {
						self.alerts.displayAlert(titled: .err, withDetail: err ?? err2 ?? "Something went wrong when updating the device", completion: nil)
						return
					}
					

				}
			}
			
			
		default:
			return
		}

		
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		PiBluetoothAPI.shared.delegate = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.player?.stop()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let addDevice = segue.destination as? AddDeviceScreen {
			addDevice.delegate = self
		} else if let editEvent = segue.destination as? EventEditScreen {
			editEvent.routine = self.routine
			if let sender = sender as? Int {
				editEvent.deviceNo = sender
				editEvent.onUpdate = {
					self.table.reloadRows(at: [IndexPath(row: editEvent.deviceNo, section: 1)], with: .automatic)
				}
			}
			if let sender = sender as? (Int, Int) {
				editEvent.deviceNo = sender.0
				let dId = self.routine.deviceIDs[sender.0]
				
				editEvent.proposedEvent = self.routine.deviceTracks[dId]?[sender.1]
				editEvent.onUpdate = {
					self.table.reloadRows(at: [IndexPath(row: editEvent.deviceNo, section: 1)], with: .automatic)
				}
			}
			editEvent.trackHeadLocation = self.getTargetPosition()
			
		}
	}
	
	// Segue Out Functions
	
	
}

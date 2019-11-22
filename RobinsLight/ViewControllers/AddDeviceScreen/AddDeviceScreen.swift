//
//  AddDevicScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import ARMDevSuite

protocol AddDeviceScreenDelegate {
	func addDeviceScreen(_ addDeviceScreen: AddDeviceScreen, didSelect device: Device)
	func addDeviceScreen(_ addDeviceScreen: AddDeviceScreen, allowDeviceSelectionFor device: Device) -> Bool
}

class AddDeviceScreen: RobinVC {
	
	// Data
	var delegate: AddDeviceScreenDelegate?
	
	
	var existingDevices = [Device]()
	
	var scanResults = [String: CBNamedPeripheral]()
	var uniques: [CBNamedPeripheral] {
		return self.scanResults.values.filter { (d) -> Bool in
			!self.existingDevices.contains(where: {$0.id == d.id})
		}.sorted { (n1, n2) -> Bool in
			let n1Rel = BluetoothManager.isRelevantDevice(n1.name)
			let n2Rel = BluetoothManager.isRelevantDevice(n2.name)
			if n1Rel == n2Rel {
				return n1.name < n2.name
			} else {
				return n1Rel
			}
		}
	}
	
	
	var pendingDevice: Device?
	
	// System
	
	// UI Components
	var navbar: UINavigationBar!
	var table: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		getData()
		initUI()
		searchForBluetoothReceivers()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		BluetoothManager.shared.manager.stopScan()
	}
	
}

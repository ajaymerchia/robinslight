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
	
	var scanResults = [String: Device]()
	var uniques: [Device] {
		return self.scanResults.values.filter { (d) -> Bool in
			!self.existingDevices.contains(where: {$0.id == d.id})
		}.sorted()
	}
	
	
	var pendingDevice: Device?
	
	// System
	
	// UI Components
	var navbar: UINavigationBar!
	var table: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		PiBluetoothAPI.shared.delegate = self
		getData()
		initUI()
		searchForBluetoothReceivers()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
//		BluetoothLib.shared.manager.stopScan()
	}
	
}

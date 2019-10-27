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
	func addDeviceScreen(_ addDeviceScreen: AddDeviceScreen, didSend device: Device)
}

class AddDeviceScreen: RobinVC {
    
    // Data
	var delegate: AddDeviceScreenDelegate?
	var scanResults = [Device]()
	var existingDevices = [Device]()
	var uniques: [Device] {
		return self.scanResults.filter { (d) -> Bool in
			!self.existingDevices.contains(where: {$0.id == d.id})
		}.sorted(by: {$0.id < $1.id})
	}
    
    // System
	
    // UI Components
	var navbar: UINavigationBar!
	var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		getData()
		initUI()
    }
    
}

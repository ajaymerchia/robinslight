//
//  ViewController.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/25/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController {
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didDiscover peripheral: CBNamedPeripheral) {
		self.updateStatus(key: "Peripheral Selected", val: peripheral.name)
		self.status = "Device identified"
	}
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didConnectTo peripheral: CBPeripheral) {
		self.updateStatus(key: "Connected", val: peripheral.name)
		self.status = "Paired to Device"
	}
	func manager(_ bluetoothManagerDelegate: BluetoothManager, canWriteTo peripheral: CBPeripheral) {
		self.status = "Ready to write"
		self.button.isEnabled = true
	}
	

	var label: UILabel!
	var button: UIButton!
	
	static var dataToSend = [
		"Winnie the Pooh",
		"Christopher Robin",
		"Piglit",
		"Eeyore",
		"Owl",
		"Joey"
	]
	
	var currValue = BluetoothViewController.dataToSend.randomElement()! {
		didSet {
			updateStatus(key: "Next To Send", val: self.currValue)
		}
	}
	
	var status = "No Info" {
		didSet {
			updateStatus(key: "Status", val: self.status)
		}
	}
	
	var statusDict: [String: String] = [:]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		initButton()
		initStatus()
		
//		BluetoothManager.shared.delegate = self
		BluetoothManager.shared.findPeripherals()
		
		updateStatus(key: "Next To Send", val: self.currValue)
		updateStatus(key: "Status", val: self.status)
		
	}
	
	func initButton() {
		button = UIButton(); view.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		
		button.setTitle("Trigger Action", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		button.setTitleColor(.gray, for: .disabled)
		button.isEnabled = false
		
		button.addTarget(self, action: #selector(sendDataToModule), for: .touchUpInside)
		
	}
	
	func initStatus() {
		self.label = UILabel(); view.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
		
		label.numberOfLines = 0
		
		setLabel()
	}
	func setLabel() {
		label.text = self.statusDict.map({ (info) -> String in
			return "\(info.key): \(info.value)"
		}).sorted().joined(separator: "\n")
	}
	func updateStatus(key: String, val: String?) {
		self.statusDict[key] = val
		setLabel()
	}
	
	@objc func sendDataToModule() {
//		BluetoothManager.shared.sendDataToPeripheral(str: currValue)
		currValue = BluetoothViewController.dataToSend.randomElement()!
	}


}


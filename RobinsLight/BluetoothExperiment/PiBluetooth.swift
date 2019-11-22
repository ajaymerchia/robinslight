//
//  PiBluetooth.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 11/21/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth

class PiBluetooth: NSObject, BluetoothManagerDelegate {
	static func isRelevant(deviceName: String) -> Bool {
		return ["PI", "RASPBERRY"].map({deviceName.uppercased().contains($0)}).contains(true)
	}
	static let shared = PiBluetooth()
	
	override init() {
		BluetoothManager.shared.findPeripherals()
	}
	
	
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didDiscover peripheral: CBNamedPeripheral) {
		if PiBluetooth.isRelevant(deviceName: peripheral.name) {
			print("will connect to \(peripheral.name)")
			BluetoothManager.shared.manager.stopScan()
			BluetoothManager.shared.connectTo(peripheral: peripheral.peripheral)
			
		}
		return
	}
	
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didConnectTo peripheral: CBPeripheral) {
		print("connected")
		print(peripheral)
		
		return
	}
	
	func manager(_ bluetoothManagerDelegate: BluetoothManager, canWriteTo peripheral: CBPeripheral, onChannel channel: CBCharacteristic) {
		return
	}
	
	
}

//
//  BluetoothManager.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/25/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		var msg = ""
        
        switch central.state {
            
            case .poweredOff:
                msg = "Bluetooth is Off"
            case .poweredOn:
                msg = "Bluetooth is On"
                manager.scanForPeripherals(withServices: nil, options: nil)
            case .unsupported:
                msg = "Not Supported"
            default:
                msg = ""
            
        }
        
        print("STATE: " + msg)
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if let name = peripheral.name {
			print(name, RSSI, advertisementData)
		}

	}
	
	static let shared = BluetoothManager()
	var manager: CBCentralManager!
	
	func findPeripherals() {
		self.manager = CBCentralManager(delegate: self, queue: nil)
		manager.scanForPeripherals(withServices: nil, options: nil)
//		manager.retrieveConnectedPeripherals(withServices: <#T##[CBUUID]#>)
	}
	
	func sendData() {
		
	}
}

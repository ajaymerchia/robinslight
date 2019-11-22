//
//  BluetoothManager.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/25/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

struct CBNamedPeripheral: Hashable, Equatable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: CBNamedPeripheral, rhs: CBNamedPeripheral) -> Bool {
		return lhs.id == rhs.id
	}
	
	var peripheral: CBPeripheral
	var name: String
	var id: String {
		return peripheral.identifier.uuidString
	}
}

protocol BluetoothManagerDelegate {
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didDiscover peripheral: CBNamedPeripheral)
	func manager(_ bluetoothManagerDelegate: BluetoothManager, didConnectTo peripheral: CBPeripheral)
	func manager(_ bluetoothManagerDelegate: BluetoothManager, canWriteTo peripheral: CBPeripheral, onChannel channel: CBCharacteristic)
}

// MARK: Bluetooth Device Setup
class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
	static let shared = BluetoothManager()
	var delegate: BluetoothManagerDelegate?
	var manager: CBCentralManager!
	
	var rwChannel: CBCharacteristic!
	var rwChannels = [UUID: CBCharacteristic]()
	var pendingPeripherals = [UUID: CBPeripheral]()
	var connectedPeripherals = [UUID: CBPeripheral]()
	
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
	
	// Discover Broadcast
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		if let name = peripheral.name {
			print(name)
			delegate?.manager(self, didDiscover: CBNamedPeripheral(peripheral: peripheral, name: name))
		}
		
	}
	// Pair
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		self.pendingPeripherals.removeValue(forKey: peripheral.identifier)
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		self.pendingPeripherals.removeValue(forKey: peripheral.identifier)
		self.connectedPeripherals[peripheral.identifier] = peripheral
		delegate?.manager(self, didConnectTo: peripheral)
		peripheral.delegate = self
		peripheral.discoverServices(nil)
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		self.connectedPeripherals.removeValue(forKey: peripheral.identifier)
	}
	// Learn
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		print("discover services called")
		
		if let servicePeripheral = peripheral.services as [CBService]? { //get the services of the perifereal
			for service in servicePeripheral {
				//Then look for the characteristics of the services
				print("found service for \(peripheral.name ?? "[unnamed]")" , service.uuid.uuidString)
				peripheral.discoverCharacteristics(nil, for: service)
			}
		}
		
		print(error)
		
	}
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		print("in discovered characteristics")
		
		if let characterArray = service.characteristics as [CBCharacteristic]? {
			for cc in characterArray {
				print("""
				-----------------------
					Peripheral: \(peripheral.name ?? "unnamed")
					Service: \(service.uuid)
					CharacteristicID: \(cc.uuid.uuidString)
					CharacteristicName: \(cc.description)
				-----------------------
				""")
				if(cc.uuid.uuidString == "FFE1") { //properties: read, write
					//if you have another BLE module, you should print or look for the characteristic you need.
					peripheral.delegate = nil
					self.rwChannels[peripheral.identifier] = cc
					self.delegate?.manager(self, canWriteTo: peripheral, onChannel: cc)
					return
				}
				
			}
		}
		
	}
	
	override init() {
		super.init()
		self.manager = CBCentralManager(delegate: self, queue: nil)
	}
	func findPeripherals() {
		manager.scanForPeripherals(withServices: nil, options: nil)
	}
	func connectTo(peripheral: CBPeripheral) {
		self.manager.stopScan()
		peripheral.delegate = self
		self.pendingPeripherals[peripheral.identifier] = peripheral
		manager.connect(peripheral, options: nil)
	}
	
	func validate(peripheral: CBPeripheral) {
		peripheral.discoverServices(nil)
	}
	
	
}

// MARK: Bluetooth Connection
extension BluetoothManager {
	func validateConnection(toDevice device: Device, completion: ErrorReturn?) {
		let test = "Hello from \(UIDevice.current.name)"
		send(data: test, to: device) { (err) in
			if let e = err {
				if e == .errUndiscoveredRWChannels {
					Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (_) in
						self.send(data: test, to: device, completion: completion)
					}
				}
			} else {
				completion?(err)
			}
			
		}
	}
	func send(data str: String, to device: Device, completion: ErrorReturn?) {
		getConnectedPeripheral(from: device) { (peripheral, err) in
			guard let peripheral = peripheral, err == nil else {
				completion?(err)
				return
			}
			
			self.baseSend(data: str, to: peripheral, completion: completion)
			
		}
	}
	
	private func getConnectedPeripheral(from device: Device, completion: Response<CBPeripheral>?) {
		if let existing = self.connectedPeripherals[device.uid] {
			if existing.state == .connected {
				completion?(existing, nil)
				return
			}
		}
		
		attemptConnection(toDevice: device, completion: completion)
		
	}
	
	private func attemptConnection(toDevice device: Device, maxScans: Int = 5, completion: Response<CBPeripheral>?) {
		guard let deviceUID = UUID(uuidString: device.id) else {
			completion?(nil, "Device ID for \(device.commonName) is corrupted.")
			return
		}
		self.findPeripherals()
		var attempts = 0
		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
			guard attempts < maxScans else {
				t.invalidate()
				completion?(nil, "Failed to find the device. Make sure it is on")
				return
			}
			attempts += 1
			let peripherals = self.manager.retrievePeripherals(withIdentifiers: [deviceUID])
			guard let found = peripherals.first else {
				return
			}
			self.connectTo(peripheral: found)
			completion?(found, nil)
			t.invalidate()
			self.manager.stopScan()
			
		}
		
	}
	
	/// Breaks apart the str into 100 character substrings and sends it to the selected peripheral
	private func baseSend(data str: String, to peripheral: CBPeripheral, completion: ErrorReturn?) {
		let maxLength = 50
		let estimatedTransmissionTime: TimeInterval = 0.5
		guard let channel = self.rwChannels[peripheral.identifier] else {
			completion?(.errUndiscoveredRWChannels)
			return
		}
		
		let chunks = str.split(by: maxLength).map({$0.data(using: String.Encoding.utf8)})
		if chunks.contains(nil) {
			completion?("Transmission data is incompatible with BLE")
			return
		}
		
		let packets = chunks.compactMap({$0})
		guard packets.count > 0 else {
			completion?("Can't send empty packets")
			return
		}
		var packetIdx = 0
		print("Writing to peripheral (\(str.count) bytes)\n", str, "\n\n\n")
		func sendPacket() {
			print("\tPacket[\(packetIdx)]: \(String(data: packets[packetIdx], encoding: .utf8)!)")
			peripheral.writeValue(packets[packetIdx], for: channel, type: .withoutResponse)
			packetIdx += 1
		}
		sendPacket()
		Timer.scheduledTimer(withTimeInterval: estimatedTransmissionTime, repeats: true) { (t) in
			guard packetIdx < packets.count else {
				t.invalidate()
				print("Finished writing")
				completion?(nil)
				return
			}
			
			sendPacket()
			
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		print("Received new value from peripheral")
		print(characteristic.value)
		let s = String(data: characteristic.value!, encoding: .utf8)
		print(s)
	}
}

// MARK: Bluetooth Utils
extension BluetoothManager {
	static func isRelevantDevice(_ str: String) -> Bool {
		return ["BT05"].contains(str.uppercased()) || ["PI", "RASPBERRY"].map({str.uppercased().contains($0)}).contains(true)
	}
}

extension String {
	static let errUndiscoveredRWChannels = "This device does not have any known read-write channels. Try again in 2-3 seconds"
	func split(by length: Int) -> [String] {
			var startIndex = self.startIndex
			var results = [Substring]()

			while startIndex < self.endIndex {
					let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
					results.append(self[startIndex..<endIndex])
					startIndex = endIndex
			}

			return results.map { String($0) }
	}
}

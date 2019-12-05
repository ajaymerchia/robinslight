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
	//	func manager(_ bluetoothManagerDelegate: BluetoothLib, didDiscover peripheral: CBNamedPeripheral)
	func manager(_ bluetoothManagerDelegate: BluetoothLib, didDisconnectFrom peripheral: CBPeripheral, explanation: String?)
//	func manager(_ bluetoothManagerDelegate: BluetoothLib, didConnectTo peripheral: CBPeripheral)
//	func manager(_ bluetoothManagerDelegate: BluetoothLib, canWriteTo peripheral: CBPeripheral, onChannel channel: CBCharacteristic)
}



// MARK: Bluetooth Library Setup
class BluetoothLib: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
	// General
	static let shared = BluetoothLib()
	var delegate: BluetoothManagerDelegate?
	private var manager: CBCentralManager!
	
	// Broadcast
	private var discoverPipes = [String: Response<CBNamedPeripheral>?]()
	
	// Connection
	var pendingPeripherals = [UUID: (CBPeripheral, ErrorReturn?)]()
	var connectedPeripherals = [UUID: CBPeripheral]()
	
	// Discovery
	var pendingServices = [UUID: (String, CBUUID, Response<CBService>?)]()
	var pendingCharacteristics = [UUID: (String, CBUUID, Response<CBCharacteristic>?)]()
	
	// Communication
	var pendingWriters = [CBUUID: ErrorReturn?]()
	var pendingReaders = [CBUUID: Response<String>?]()
	
	override init() {
		super.init()
		self.manager = CBCentralManager(delegate: self, queue: nil)
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		var msg = ""
		switch central.state {
		case .poweredOff:
			msg = "Bluetooth is Off"
		case .poweredOn:
			msg = "Bluetooth is On"
		case .unsupported:
			msg = "Not Supported"
		default:
			msg = ""
			
		}
		print("STATE: " + msg)
	}
}

// MARK: Discover Broadcast
extension BluetoothLib {
	func pipeDevices(for clientID: String, onDevice: Response<CBNamedPeripheral>?) {
		self.discoverPipes[clientID] = onDevice
		
		if !self.manager.isScanning {
			self.manager.scanForPeripherals(withServices: nil)
			Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
				guard self.manager.state != .poweredOn else {
					self.manager.scanForPeripherals(withServices: nil)
					t.invalidate()
					return
				}
				self.manager.scanForPeripherals(withServices: nil)

			}

		}
	}
	func stopPipingDevices(to clientID: String) {
		self.discoverPipes.removeValue(forKey: clientID)
		if self.discoverPipes.count == 0 {
			self.manager.stopScan()
		}
	}
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if let name = peripheral.name {
			for client in self.discoverPipes {
				client.value?(CBNamedPeripheral(peripheral: peripheral, name: name), nil)
			}
		}
	}
}

// MARK: Pairing
extension BluetoothLib {
	func connectTo(peripheral: CBPeripheral, completion: ErrorReturn?) {
		peripheral.delegate = self
		self.pendingPeripherals[peripheral.identifier] = (peripheral, completion)
		self.manager.connect(peripheral, options: nil)
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		self.pendingPeripherals.removeValue(forKey: peripheral.identifier)?.1?(nil)
		self.connectedPeripherals[peripheral.identifier] = peripheral
	}
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		self.pendingPeripherals.removeValue(forKey: peripheral.identifier)?.1?(error?.localizedDescription ?? "Failed to connect to \(peripheral.identifier)")
	}
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		self.connectedPeripherals.removeValue(forKey: peripheral.identifier)
		self.delegate?.manager(self, didDisconnectFrom: peripheral, explanation: error?.localizedDescription)
		print(error)
	}
}

// MARK: Service Usage
extension BluetoothLib {
	func write(data str: String, to peripheral: CBNamedPeripheral, over channel: CBCharacteristic, completion: ErrorReturn?) {
		
		guard let data = str.data(using: .utf8) else {
			completion?("Failed to generate data from transmission string\n\(str)")
			return
		}
		
		self.pendingWriters[channel.uuid] = completion
		
		peripheral.peripheral.delegate = self
		peripheral.peripheral.writeValue(data, for: channel, type: .withResponse)
		
		
	}
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		if let handler = self.pendingWriters.removeValue(forKey: characteristic.uuid) as? ErrorReturn {
			handler(error?.localizedDescription)
		}
	}
	
	
	
	func read(from peripheral: CBNamedPeripheral, from channel: CBCharacteristic, completion: Response<String>?) {
		
		
		self.pendingReaders[channel.uuid] = completion
		peripheral.peripheral.delegate = self
		peripheral.peripheral.readValue(for: channel)
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		
		if let handler = self.pendingReaders.removeValue(forKey: characteristic.uuid) as? Response<String> {
			
			guard
				let data = characteristic.value,
				let value = String(data: data, encoding: .utf8),
				error == nil
		  else {
				handler(nil, error?.localizedDescription)
				return
			}
			
			handler(value, nil)
		}
	}
	
}

// MARK: Service Discovery
extension BluetoothLib {
	func find(service: PiService, on peripheral: CBNamedPeripheral, timeOut: TimeInterval = 10, completion: Response<CBService>?) {
		if let cached = peripheral.peripheral.services?.first(where: {$0.uuid == service.uid}) {
			completion?(cached, nil)
			return
		}
		peripheral.peripheral.delegate = self
		
		let requestID = UUID().uuidString
		self.pendingServices[peripheral.peripheral.identifier] = (requestID, service.uid, completion)
		peripheral.peripheral.discoverServices([service.uid])
		
		Timer.scheduledTimer(withTimeInterval: timeOut, repeats: false) { (_) in
			if let hdlr = self.pendingServices[peripheral.peripheral.identifier] {
				guard hdlr.0 == requestID else {
					return
				}
				self.pendingServices.removeValue(forKey: peripheral.peripheral.identifier)
				hdlr.2?(nil, "Request timed out. Failed to find service.")
				
			}
		}
	}
	
	func find(channel: PiChannel, on service: CBService, on peripheral: CBNamedPeripheral, timeOut: TimeInterval = 10, completion: Response<CBCharacteristic>?) {
		
		if let cached = service.characteristics?.first(where: {$0.uuid == channel.uid}) {
			completion?(cached, nil)
			return
		}
		peripheral.peripheral.delegate = self
		
		let requestID = UUID().uuidString
		self.pendingCharacteristics[peripheral.peripheral.identifier] = (requestID, channel.uid, completion)
		peripheral.peripheral.discoverCharacteristics([channel.uid], for: service)
//		peripheral.peripheral.discoverCharacteristics(nil, for: service)
		
		Timer.scheduledTimer(withTimeInterval: timeOut, repeats: false) { (_) in
			if let hdlr = self.pendingCharacteristics[peripheral.peripheral.identifier] {
				guard hdlr.0 == requestID else {
					return
				}
				self.pendingCharacteristics.removeValue(forKey: peripheral.peripheral.identifier)
				hdlr.2?(nil, "Request timed out. Failed to find service.")
				
			}
		}
		
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		let handler = self.pendingServices.removeValue(forKey: peripheral.identifier)

		guard let services = peripheral.services, error == nil else {
			handler?.2?(nil, error?.localizedDescription)
			return
		}
		
		for service in services {
			if service.uuid == handler?.1 {
				handler?.2?(service, nil)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		let handler = self.pendingCharacteristics.removeValue(forKey: peripheral.identifier)
		
		guard let characteristics = service.characteristics, error == nil else {
			handler?.2?(nil, error?.localizedDescription)
			return
		}
		
		for crcrtr in characteristics {
			if crcrtr.uuid == handler?.1 {
				handler?.2?(crcrtr, nil)
			}
		}
		
		/*
		print("""
		-----------------------
		Peripheral: \(peripheral.name ?? "unnamed")
		Service: \(service.uuid)
		CharacteristicID: \(cc.uuid.uuidString)
		CharacteristicAbilities: \(cc.properties.description)
		-----------------------
		""")
		*/
		
		
	}
}

// MARK: Bluetooth Utils
extension BluetoothLib {
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

extension CBCharacteristicProperties {
	var canRead: Bool {
		return self.contains(.read)
	}
	var canWrite: Bool {
		return self.contains(.write)
	}
	var description: String {
		return [canRead ? "read" : nil, canWrite ? "write" : nil].compactMap({$0}).joined(separator: ", ")
	}
}

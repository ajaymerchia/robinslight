//
//  PiBluetooth.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 11/21/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth

/// API that uses the Bluetooth Utils Lib to operate at the application layer. The CBManager should not be accessible beyond this layer. Converts Device to CBNamedPeripherals
protocol PiBluetoothAPIDelegate {
	func piAPI(piAPI: PiBluetoothAPI, disconnectedFrom device: Device, explanation: String?)
}

enum PiChannel: String {
	// Channels for PingPongService
	case pingpong = "8e66b5c3-9851-4a29-8252-295ad263f4b1"
	
	// Channels for PiServices
	case memory = "ff51b30e-d7e2-4d93-8842-a7c4a57dfb01"
	case uptime = "ff51b30e-d7e2-4d93-8842-a7c4a57dfb02"
	case loadaverage = "ff51b30e-d7e2-4d93-8842-a7c4a57dfb03"
	
	var uid: CBUUID {
		return CBUUID(string: self.rawValue)
	}
}

enum PiService: String {
	case pingpong = "8e66b5c3-9851-4a29-8252-295ad263f4b0"
	case sysinfo = "ff51b30e-d7e2-4d93-8842-a7c4a57dfb00"
	
	var channels: [PiChannel] {
		switch self {
		case .pingpong:
			return [.pingpong]
		case .sysinfo:
			return [.memory, .uptime, .loadaverage]
		}
	}
	var uid: CBUUID {
		return CBUUID(string: self.rawValue)
	}
}






class PiBluetoothAPI: NSObject, BluetoothManagerDelegate {
	static func isRelevant(deviceName: String) -> Bool {
		return ["PI", "RASPBERRY"].map({deviceName.uppercased().contains($0)}).contains(true)
	}
	static let shared = PiBluetoothAPI()
	var delegate: PiBluetoothAPIDelegate?
	private let _id = UUID().uuidString

	private var isScanning: Bool = false
	private var knownPeripherals = [String: CBNamedPeripheral]()
	private var connectedDevices = [String: Device]()
	
	override init() {
		super.init()
		BluetoothLib.shared.delegate = self
	}
}

// MARK: Discover Broadcast Services
extension PiBluetoothAPI {
	func findDevices(filterForPis: Bool = false, timeOut: TimeInterval = 15, onNewDevice: Response<Device>?) {
		guard !isScanning else {
			print("API MISUSE: PiBluetoothAPI is already scanning for devices")
			return
		}
		
		BluetoothLib.shared.pipeDevices(for: self._id) { (peripheral, err) in
			self.isScanning = true
			guard let peripheral = peripheral, err == nil else {
				onNewDevice?(nil, err)
				return
			}
			self.knownPeripherals[peripheral.id] = peripheral
			
			guard !filterForPis || PiBluetoothAPI.isRelevant(deviceName: peripheral.name) else {
				print("Filtering device \(peripheral.name)")
				return
			}
			
			let device = Device(id: peripheral.id, commonName: peripheral.name)
			
			onNewDevice?(device, nil)
			
		}
		
		Timer.scheduledTimer(withTimeInterval: timeOut, repeats: false) { (_) in
			self.stopSearching()
		}
		
		
	}
	func stopSearching() {
		BluetoothLib.shared.stopPipingDevices(to: self._id)
		self.isScanning = false
	}
}

// MARK: Connection & Reconnection Services
extension PiBluetoothAPI {
	func connectTo(device: Device, completion: ErrorReturn?) {
		func connectHelper(peripheral: CBNamedPeripheral) {
			self.connectTo(peripheral: peripheral) { (err) in
				if err == nil {
					self.connectedDevices[peripheral.id] = device
				}
				completion?(err)
			}
		}
		
		findPeripheral(for: device) { (peripheral, err) in
			guard let peripheral = peripheral, err == nil else {
				completion?("Could not find \(device.commonName)")
				return
			}
			connectHelper(peripheral: peripheral)
		}
	}
	/// Validates the compatibility of the device using the pingpong service and testing for accuracy
	/// - Parameters:
	///   - device: Device that we want to validate
	///   - completion: Informs called if there was an error
	func validateCompatibility(for device: Device, completion: ErrorReturn?) {
		let testString = UUID().uuidString
		self.write(data: testString, device: device, service: .pingpong, channel: .pingpong) { (err) in
			guard err == nil else { completion?(err); return }
			self.read(device: device, service: .pingpong, channel: .pingpong) { (data, err) in
				guard let data = data, err == nil else { completion?(err); return }
				
				if testString != data {
					completion?("PingPongAuth service failed to respond correctly.")
				} else {
					completion?(nil)
				}
				
			}
			
			
		}
	}
	
	private func connectTo(peripheral: CBNamedPeripheral, completion: ErrorReturn?) {
		BluetoothLib.shared.connectTo(peripheral: peripheral.peripheral) { (err) in
			completion?(err)
		}
	}
	private func findPeripheral(for device: Device, completion: Response<CBNamedPeripheral>?) {
		
		guard let peripheral = knownPeripherals[device.id] else {
			// use BluetoothLib to search for it
			
			
			return
		}
		completion?(peripheral, nil)
		
	}
	func manager(_ bluetoothManagerDelegate: BluetoothLib, didDisconnectFrom peripheral: CBPeripheral, explanation: String?) {
		guard let d = self.connectedDevices[peripheral.identifier.uuidString] else { return }
		
		self.delegate?.piAPI(piAPI: self, disconnectedFrom: d, explanation: explanation)
	}
}

// MARK: Services & Characteristics Interactions
extension PiBluetoothAPI {
	func write(data: String, device: Device, service: PiService, channel: PiChannel, completion: ErrorReturn?) {
		
		// Validate that channel belongs to service
		fetchCBResources(device: device, service: service, channel: channel) { (cbresources, err) in
			
			guard let cbresources = cbresources, err == nil else {
				completion?(err)
				return
			}
			
			BluetoothLib.shared.write(data: data, to: cbresources.0, over: cbresources.1, completion: completion)
			
		}
	}
	
	func read(device: Device, service: PiService, channel: PiChannel, completion: Response<String>?) {
		
		// Validate that channel belongs to service
		fetchCBResources(device: device, service: service, channel: channel) { (cbresources, err) in
			guard let cbresources = cbresources, err == nil else {
				completion?(nil, err)
				return
			}
			
			BluetoothLib.shared.read(from: cbresources.0, from: cbresources.1, completion: completion)
			
		}
	}
	
	private func fetchCBResources(device: Device, service: PiService, channel: PiChannel, completion: Response<(CBNamedPeripheral, CBCharacteristic)>?) {
		
		
		func getServiceAndChannel(peripheral: CBNamedPeripheral) {
			BluetoothLib.shared.find(service: service, on: peripheral) { (cbservice, err) in
				guard let cbservice = cbservice, err == nil else {
					completion?(nil, err)
					return
				}
				
				print("Found service \(service)")
				
				BluetoothLib.shared.find(channel: .pingpong, on: cbservice, on: peripheral) { (characteristic, err) in
					guard let characteristic = characteristic, err == nil else {
						completion?(nil, err)
						return
					}
					
					print("Found channel \(channel)")
					
					completion?((peripheral, characteristic), nil)
					
				}
				
			}

		}
		
		guard service.channels.contains(channel) else {
			completion?(nil, "\(channel) does not belong to \(service)")
			return
		}
		
		self.findPeripheral(for: device) { (peripheral, err) in
			guard let peripheral = peripheral, err == nil else {
				completion?(nil, err)
				return
			}
			print("Found peripheral \(peripheral.name)")
			
			if peripheral.peripheral.state != .connected {
				self.connectTo(peripheral: peripheral) { (err) in
					guard err == nil else {
						completion?(nil, err)
						return
					}
					
					getServiceAndChannel(peripheral: peripheral)
				}
			} else {
				getServiceAndChannel(peripheral: peripheral)
			}
		}
		
	}
	
}





extension Device: Comparable {
	var isRelevant: Bool {
		return PiBluetoothAPI.isRelevant(deviceName: self.commonName)
	}
	static func < (lhs: Device, rhs: Device) -> Bool {
		if lhs.isRelevant == rhs.isRelevant {
			return lhs.commonName < rhs.commonName
		} else {
			return lhs.isRelevant
		}
	}
	
	static func == (lhs: Device, rhs: Device) -> Bool {
		return lhs.uid == rhs.uid
	}
}

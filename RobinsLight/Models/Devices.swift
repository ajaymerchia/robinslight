//
//  Devices.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth

class Device: DataBlob {
	static var dbRef: String = "devices"
	
	var uid: UUID {
		return UUID(uuidString: self.id)!
	}
	/// The Peripheral ID of the device
	var id: String
	var commonName: String
	
//	var rwChannel: CBCharacteristic
	
	init(id: String, commonName: String) {
		self.id = id
		self.commonName = commonName
	}
	
}

extension Device {
	static let names = [
		"Ajay's Box",
		"Abhinav's Box",
		"Shreyas' Box",
		"Kush's Box",
		"Yash's Box",
		"Richa's Box",
		"Divya's Box"
		
	]
	static let sampleDevices = names.map({Device(id: String($0.sha256().prefix(12)), commonName: $0)})
}

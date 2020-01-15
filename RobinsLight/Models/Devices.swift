//
//  Devices.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import CoreBluetooth
import ARMDevSuite

class Device: DataBlob {
	static var dbRef: String = "devices"
	
	var uid: UUID {
		return UUID(uuidString: self.id)!
	}
	/// The Peripheral ID of the device
	var id: String
	var commonName: String
	var isReal: Bool
	
//	var rwChannel: CBCharacteristic
	
	init(fakeName: String) {
		self.commonName = fakeName
		self.id = LogicSuite.uuid()
		self.isReal = false
	}
	
	init(id: String, commonName: String) {
		self.id = id
		self.commonName = commonName
		self.isReal = true
	}
	
}

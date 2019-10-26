//
//  RoutineEditorScreen-runtime.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen {

	@objc func startRunTime() {
		self.isPlaying.toggle()
		self.setNav()
	}
	@objc func stopRunTime() {
		self.isPlaying.toggle()
		self.setNav()
	}

}

//
//  RoutineManagerScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import ARMDevSuite

class RoutineManagerScreen: RobinVC {
	
	// Data
	static var allRoutines = [Routine]()
	
	// System
	var table: UITableView!
	// UI Components
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		initUI()
		self.getData()
		

		
	}
	
}

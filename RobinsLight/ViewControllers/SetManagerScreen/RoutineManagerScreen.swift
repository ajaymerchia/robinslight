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
		

		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		// make Routine & Devices Blob if it doesn't exist.
//		RobinCache.records(for: Routine.self).store(<#T##obj: Routine##Routine#>, completion: <#T##ErrorReturn?##ErrorReturn?##(RobinError?) -> ()#>)
		
		self.getData()

	}
	
	
	
}

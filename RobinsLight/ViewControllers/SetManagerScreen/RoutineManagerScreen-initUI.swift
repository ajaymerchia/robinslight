//
//  RoutineManagerScreen-initUI.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// UI Initialization - Create the View

import Foundation
import UIKit
import ARMDevSuite

extension RoutineManagerScreen {
    func initUI() {
        buildViews()
        populateViews()
    }
    
    func buildViews() {
        initNav()
		initTable()
    }
    
    func populateViews() {
        
    }

    // UI Initialization Helpers
	func initNav() {
		self.title = "My Sets"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewSet))
	}
	func initTable() {
		self.table = UITableView(); view.addSubview(table)
		table.pinSafeTo(self.view)
		table.delegate = self
		table.dataSource = self
	}

}

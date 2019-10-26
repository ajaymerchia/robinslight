//
//  RoutineEditorScreen-initUI.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// UI Initialization - Create the View

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen {
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
		self.title = self.routine.title
		
		self.play = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startRunTime))
		self.pause = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(startRunTime))
		
		setNav()
	}
	func setNav() {
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAsset)),
			self.isPlaying ? self.pause : self.play
		]
	}
	func initTable() {
		self.table = UITableView(); view.addSubview(table)
		table.pinSafeTo(self.view)
		table.dataSource = self
		table.delegate = self
//		table.allowsSelection = false
		table.contentInset = UIEdgeInsets(top: 2 * .padding, left: 0, bottom: 0, right: 0)
		table.delaysContentTouches = false
		table.register(TimelineCell.self, forCellReuseIdentifier: TimelineCell.kID)
		
		
	}

}

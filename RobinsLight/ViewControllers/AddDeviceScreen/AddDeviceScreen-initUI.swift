//
//  AddDeviceScreen-initUI.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// UI Initialization - Create the View

import Foundation
import UIKit
import ARMDevSuite

extension AddDeviceScreen {
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
		navbar = UINavigationBar(); view.addSubview(navbar)
		navbar.translatesAutoresizingMaskIntoConstraints = false
		navbar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		navbar.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		let navItem = UINavigationItem(title: "Add a Stage Asset")
		navItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(searchForBluetoothReceivers)),
			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFakeDevice))
		]
		navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissSelf))
		
		
		navbar.setItems([navItem], animated: true)
	}
	
	@objc func dismissSelf() {
		self.dismiss(animated: true, completion: nil)
	}
	func initTable() {
		self.table = UITableView(); view.addSubview(table)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		table.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: .padding).isActive = true
		
		table.delegate = self
		table.dataSource = self
	}

}

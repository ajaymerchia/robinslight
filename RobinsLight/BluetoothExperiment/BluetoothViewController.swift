//
//  ViewController.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/25/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

class BluetoothViewController: UIViewController {

	var label: UILabel!
	var button: UIButton!
	
	static var dataToSend = [
		"Winnie the Pooh",
		"Christopher Robin",
		"Piglit",
		"Eeyore",
		"Owl",
		"Joey"
	]
	
	var currValue = BluetoothViewController.dataToSend.randomElement()! {
		didSet {
			setLabel()
		}
	}
	var status = "No Info" {
		didSet {
			setLabel()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		initButton()
		initStatus()
		
		BluetoothManager.shared.findPeripherals()
		
	}
	
	func initButton() {
		button = UIButton(); view.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		
		button.setTitle("Trigger Action", for: .normal)
		button.setTitleColor(.blue, for: .normal)
		
		
	}
	
	func initStatus() {
		self.label = UILabel(); view.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
		
		label.numberOfLines = 0
		
		setLabel()
	}
	func setLabel() {
		label.text = """
		Next To Send: \(currValue)
		Status: \(status)
		"""
	}
	
	@objc func sendDataToModule() {
		
	}


}


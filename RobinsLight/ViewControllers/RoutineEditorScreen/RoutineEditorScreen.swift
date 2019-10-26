//
//  RoutineEditorScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import ARMDevSuite

class RoutineEditorScreen: RobinVC {
    
	static var secondsToPixels: CGFloat = 10
	static var secondsMajorMarker: CGFloat = 5
	
    // Data
	var isPlaying: Bool = false
	var routine: Routine!
    
    // System
    
    // UI Components
	var play: UIBarButtonItem!
	var pause: UIBarButtonItem!
	var table: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		initUI()
        
    }
    
}

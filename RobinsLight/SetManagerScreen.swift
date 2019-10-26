//
//  SetManagerScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import ARMDevSuite

class SetManagerScreen: UIViewController {
    
    // Data
    
    // System
    var alerts: AlertManager!
    
    // UI Components
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getData()
        setupManagers()
        initUI()
    }
    
}

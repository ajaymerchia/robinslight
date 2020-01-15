//
//  RoutineManagerScreen-sys.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// System - Segues, Observers, Managers, and UI Event Triggers

import Foundation
import UIKit
import ARMDevSuite

extension RoutineManagerScreen {

    override func viewWillAppear(_ animated: Bool) {

    }

    

    override func viewWillDisappear(_ animated: Bool) {
        
    }
	override func viewDidDisappear(_ animated: Bool) {
		self.alerts.dismissHUD()
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let editor = segue.destination as? RoutineEditorScreen {
			editor.routine = sender as? Routine
		}
    }

    // Segue Out Functions


}

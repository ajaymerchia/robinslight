//
//  RoutineManagerScreen-logic.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite

extension RoutineManagerScreen {
	func getData() {
		RoutineManagerScreen.allRoutines = []
		DataStack.list(type: Routine.self) { (routineIDs, err) in
			guard let ids = routineIDs else {
				self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
				return
			}
			
			DispatchGroup(vals: ids, forEach: { (id, g) in
				RobinCache.records(for: Routine.self).get(id: id) { (r, err) in
					if let r = r {
						RoutineManagerScreen.allRoutines.append(r)
					} else {
						print(err)
					}
					g.leave()
				}
			}).notify(queue: .main) {
				self.table.reloadData()
			}
		}
	}
	
	@objc func addNewSet() {
		self.alerts.getTextInput(withTitle: "Create New Set", andHelp: "What is the name of this new set?", andPlaceholder: "A11 @ Legends", completion: { (setName) in
			guard setName != "" else {
				self.alerts.displayAlert(titled: .err, withDetail: "Set name should not be empty", completion: nil)
				return
			}
			
			self.alerts.startProgressHud(withTitle: "Creating Set...")
			RoutineManager.shared.createNewRoutine(titled: setName) { (routine, err) in
				guard let routine = routine, err == nil else {
					self.alerts.triggerHudFailure(withHeader: .err, andDetail: err)
					return
				}
				Timer.fire(after: 0.5) {
					RoutineManagerScreen.allRoutines.append(routine)
					self.table.reloadData()
					self.alerts.dismissHUD()
				}
				
			}
			
		})
	}
	
	
}

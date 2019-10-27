//
//  RoutineManagerScreen-table.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Protocol Conformance for SetManagerScreen_table

import Foundation
import UIKit
import ARMDevSuite

extension RoutineManagerScreen: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return RoutineManagerScreen.allRoutines.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		let routine = fetch(indexPath)
		cell.textLabel?.text = routine.title
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let targeted = fetch(indexPath)

			RobinCache.records(for: Routine.self).delete(id: targeted.id) { (err) in
				guard err == nil else {
					self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
					return
				}
				RoutineManagerScreen.allRoutines.remove(at: indexPath.row)
				tableView.deleteRows(at: [indexPath], with: .fade)
			}
			
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		self.alerts.startProgressHud(withTitle: "Loading \(RoutineManagerScreen.allRoutines[indexPath.row].title)")
		Timer.fire(after: 0.5) {
			self.performSegue(withIdentifier: "2editor", sender: self.fetch(indexPath))
		}
		
	}
	
	func fetch(_ indexPath: IndexPath) -> Routine {
		return RoutineManagerScreen.allRoutines[indexPath.row]
	}

}

//
//  SetManager.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
class RoutineManager {
	static let shared = RoutineManager()
	
	func createNewRoutine(titled: String, completion: Response<Routine>?) {
		let routine = Routine(title: titled)
		RobinCache.records(for: Routine.self).store(routine) { (err) in
			guard err == nil else {
				completion?(nil, err)
				return
			}
			completion?(routine, nil)
			
		}
	}
}

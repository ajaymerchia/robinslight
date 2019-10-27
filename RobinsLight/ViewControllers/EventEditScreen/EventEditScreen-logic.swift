//
//  EventEditScreen-logic.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/27/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite

extension EventEditScreen {
    func getData() {
    
    }
	@objc func storeEvent() {
		let dId = self.routine.deviceIDs[self.deviceNo]
		if self.routine.deviceTracks[dId]!.contains(self.proposedEvent) {
			// replace -- I should just mutating a record in place, store, dismiss
			RobinCache.records(for: Routine.self).store(self.routine) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		} else {
			self.routine.deviceTracks[dId]!.append(self.proposedEvent)
			RobinCache.records(for: Routine.self).store(self.routine) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		}
	}


}

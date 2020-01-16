//
//  RoutineEditorScreen-masterPlayer.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 1/15/20.
//  Copyright © 2020 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen {
	static let masterPlayerTag: Int = Int.random(in: 0...2000)
	
	@objc func showMisc() {
		self.alerts.showActionSheet(withTitle: "Options", andDetail: nil, configs: [
			!self.isShowingPlayer ?
				ActionConfig(title: "Open Master Player", style: .default, callback: {
						self.openMasterPlayer()
				}) :
				ActionConfig(title: "Close Master Player", style: .default, callback: {
					self.closeMasterPlayer()
				})
		])
	}
	
	@objc func closeMasterPlayer() {
		self.view.viewWithTag(RoutineEditorScreen.masterPlayerTag)?.removeFromSuperview()
		self.table.isScrollEnabled = true
		self.isShowingPlayer = false
		self.masterDevices = []
	}
	
	func getAllDevices(completion: Response<[Device]>?) {
		var ds = [Device]()
		
		let g = DispatchGroup(count: self.routine.deviceIDs.count)
		self.routine.deviceIDs.forEach { (id) in
			RobinCache.records(for: Device.self).get(id: id) { (d, _) in
				if let d = d { ds.append(d) }
				g.leave()
			}
		}
		
		g.notify(queue: .main) {
			completion?(ds, nil)
		}
		
		
	}
	
	@objc func openMasterPlayer() {
		// puts a simple pause play interface over the table. Restricts scrolling in the main table. Still gives access to the slider.
		func fail(err: String) {
			self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
		}
		guard !self.routine.deviceIDs.isEmpty else { fail(err: "Need at least 1 device to use player."); return }
		self.table.setContentOffset(CGPoint(x: 0, y: -50), animated: false)
		
		guard let header = self.table.cellForRow(at: IndexPath(row: 0, section: 1)) else {
			guard !self.routine.deviceIDs.isEmpty else { fail(err: "Failed to detect target height of the player."); return }
			return
		}
		
		self.table.isScrollEnabled = false
		self.isShowingPlayer = true
		self.getAllDevices { (ds, _) in
			if let ds = ds {
				self.masterDevices = ds
			}
		}
		
		
		let player = UIView(); self.view.addSubview(player)
		player.translatesAutoresizingMaskIntoConstraints = false
		player.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
		player.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
		player.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		player.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		
		
		player.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		player.tag = RoutineEditorScreen.masterPlayerTag
		
		let playerToggle = UIButton(); player.addSubview(playerToggle)
		playerToggle.center(in: player)
		playerToggle.widthAnchor.constraint(equalTo: player.widthAnchor, multiplier: 0.5).isActive = true
		playerToggle.heightAnchor.constraint(equalTo: playerToggle.widthAnchor).isActive = true
		
		
		playerToggle.setBackgroundImage(UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
		playerToggle.setBackgroundImage(UIImage(systemName: "stop.fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
		
		playerToggle.addTarget(self, action: #selector(masterPlayerToggle(_:)), for: .touchUpInside)
		
	}
	
	@objc func masterPlayerToggle(_ sender: UIButton) {
		sender.isSelected.toggle()
		
		if sender.isSelected {
			// start runtime and issue start command to all devices
			let start = Date()
			self.startRunTime()
			for d in self.masterDevices {
				self.playRoutine(forDevice: d, refDate: start)
			}
			
		} else {
			// stop runtime and issue stop command to all devices
			self.stopRunTime()
			for d in self.masterDevices {
				self.stopRoutine(forDevice: d)
			}
		}
		
	}
}

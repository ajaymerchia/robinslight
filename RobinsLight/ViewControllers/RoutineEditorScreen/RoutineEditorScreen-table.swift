//
//  RoutineEditorScreen-table.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Protocol Conformance for RoutineEditorScreen_table

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen: UITableViewDelegate, UITableViewDataSource, TimelineCellDelegate, UIScrollViewDelegate {
	func didSelectTimelineTitle(_ cell: TimelineCell) {
		let deviceID = self.routine.deviceIDs[cell.editorIdx]
		RobinCache.records(for: Device.self).get(id: deviceID) { (d, err) in
			guard let device = d, err == nil else {
				self.alerts.displayAlert(titled: .err, withDetail: "Couldn't find the device object for this ID. Try removing and re-adding this device.", completion: nil)
				return
			}
			
			self.showOptions(forDevice: device)
		}
	}
	
	func didSelectDeleteButton(_ cell: TimelineCell) {
		let deviceID = self.routine.deviceIDs[cell.editorIdx]
		
		func delete() {
			self.routine.deviceTracks.removeValue(forKey: deviceID)
			self.routine.deviceIDs.remove(at: cell.editorIdx)
			
			self.table.deleteRows(at: [IndexPath(row: cell.editorIdx, section: 1)], with: .automatic)
			
			RobinCache.records(for: Routine.self).store(self.routine, completion: nil)
		}
		
		RobinCache.records(for: Device.self).get(id: deviceID) { (d, err) in
			guard let d = d, err == nil else {
				self.alerts.displayAlert(titled: .err, withDetail: err) {
					self.alerts.askYesOrNo(question: "Since the device is failing would you like to delete this track?", helpText: nil) { (d) in
						if d { delete() }
					}
				}
				
				
				return
			}
			
			let vc = UIAlertController(title: "Are you sure you want to remove \(d.commonName) (\(d.id))", message: "You will lose any events tuned for this device as well.", preferredStyle: .alert)
			
			vc.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
				// delete
				delete()
				
			}))
			vc.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
			
			self.present(vc, animated: true, completion: nil)
			
			
		}
		
		
	}
	
	func didSelectTimelineBar(_ cell: TimelineCell, at idx: Int) {
		if cell.editorIdx == -1 {
			self.editSongPosition(idx: idx)
		} else {
			guard let event = self.routine.deviceTracks[self.routine.deviceIDs[cell.editorIdx]]?[idx] else {
				self.alerts.displayAlert(titled: .err, withDetail: "Failed to load event", completion: nil)
				return
			}
			self.alerts.showActionSheet(withTitle: event.name, andDetail: nil, configs: [
				ActionConfig(title: "Edit Event", style: .default, callback: {
					self.performSegue(withIdentifier: "2eventEdit", sender: (cell.editorIdx, idx))
				}),
				ActionConfig(title: "Copy Event", style: .default, callback: {
					self.copyEvent(e: event, sourceTrack: cell.editorIdx)
				})
			])
			
		}
	}
	
	func didSelectAddButton(_ cell: TimelineCell) {
		if cell.editorIdx == -1 {
			self.requestNewSong()
		} else {
			self.addEvent(in: cell.editorIdx)
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return nil
		}
		
		let view = UIView()
		view.backgroundColor = UIColor.robinSecondary.withAlphaComponent(0.5)
		let label = UILabel(); view.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding).isActive = true
		
		label.text = ["Track", "Stage Assets"][section]
		label.textColor = .robinBlack
		label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
		
		let container = UIView()
		container.backgroundColor = .white
		container.addSubview(view)
		view.pinTo(container)
		
		return container
		
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : self.routine.deviceIDs.count
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 0 ? 0 : 40
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			self.persistentTrackCell.scrollView?.delegate = self
			return self.persistentTrackCell
		} else {
			let id = self.routine.deviceIDs[indexPath.row]
			let events = self.routine.deviceTracks[id] ?? []
			
			let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.kID) as! TimelineCell
			cell.awakeFromNib()
			cell.initFrom(timelineComponents: events, isDeviceTrack: true, totalLength: self.scrollViewWidth)
			cell.editorIdx = indexPath.row
			cell.delegate = self
			
			cell.scrollView?.delegate = self
			
			RobinCache.records(for: Device.self).get(id: id) { (d, _) in
				guard let d = d else { return }
				
				cell.trackTitle = d.commonName + (d.isReal ? "" : " [Fake]")
				cell.additionalInfo = id
				
			}
			
			return cell
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView != self.table {
			scrollers.forEach { (sv) in
				sv.contentOffset = scrollView.contentOffset
			}
		}
		
	}
	
	
}

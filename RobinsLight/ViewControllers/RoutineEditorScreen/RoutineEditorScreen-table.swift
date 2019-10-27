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

extension RoutineEditorScreen: UITableViewDelegate, UITableViewDataSource, TimelineCellDelegate {
	func didSelectTimelineBar(_ cell: TimelineCell, at idx: Int) {
		if cell.editorIdx == -1 {
			self.editSongPosition(idx: idx)
		}
	}
	
	func didSelectAddButton(_ cell: TimelineCell) {
		if cell.editorIdx == -1 {
			self.requestNewSong()
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
		
		
		return view
	
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : 2
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 0 ? 0 : 40
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			return self.persistentTrackCell
		} else {
			return UITableViewCell()
		}
	}
	

}

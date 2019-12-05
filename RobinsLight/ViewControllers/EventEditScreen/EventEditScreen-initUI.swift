//
//  EventEditScreen-initUI.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/27/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// UI Initialization - Create the View

import Foundation
import UIKit
import ARMDevSuite

extension EventEditScreen {
    func initUI() {
        buildViews()
        populateViews()
    }
    
    func buildViews() {
        initNav()
		initTitle()
		initPreviewBox()
		initCoreEventRequirements()
		effectLocalHeader()
    }
    
    func populateViews() {
		titleTf.text = self.proposedEvent.name
		eventTypePicker.setTitle("Set Effect Type: \(self.proposedEvent.type.rawValue.capitalized)", for: .normal)
		
		self.effectTypeMarker.text = "\(self.proposedEvent.type.rawValue.capitalized) Settings"
		
		func format(btn: UIButton, label: String, val: TimeInterval) {
			btn.setTitle("\(label)\n\(val.clockStyleMilli!)", for: .normal)
		}
		
		format(btn: self.start, label: "Start", val: self.proposedEvent.timelineStart)
		format(btn: self.end, label: "End", val: self.proposedEvent.timelineEnd)
		format(btn: durationButton, label: "Duration", val: self.proposedEvent.timelineDuration)
		
		self.table.reloadData()
		table.allowsSelectionDuringEditing = true
		
    }

    // UI Initialization Helpers
	func initNav() {
		navbar = UINavigationBar(); view.addSubview(navbar)
		navbar.translatesAutoresizingMaskIntoConstraints = false
		navbar.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		navbar.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		let navItem = UINavigationItem(title: "Add Effect")
		navItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(storeEvent))
		navItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteEvent))
		
		
		navbar.setItems([navItem], animated: true)
	}
	
	@objc func deleteEvent() {
		let id = self.routine.deviceIDs[self.deviceNo]
		self.routine.deviceTracks[id]?.removeAll(where: {$0.id == self.proposedEvent.id})
		RobinCache.records(for: Routine.self).store(self.routine) { (_) in
			self.onUpdate?()
			self.dismiss(animated: true, completion: nil)
		}
		
	}
	
	func initTitle() {
		let tf = ARMTextField(); view.addSubview(tf)
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		tf.topAnchor.constraint(equalTo: navbar.bottomAnchor, constant: .padding * 2).isActive = true
		tf.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
		
		tf.placeholder = "Name This Effect"
		tf.textColor = .robinPrimary
		tf.tintColor = .robinPrimary
		
		tf.lineColor = .robinDarkGray
		tf.placeholderColor = .robinDarkGray
		tf.titleColor = .robinDarkGray
		
		tf.selectedLineColor = .robinPrimary
		tf.selectedTitleColor = .robinPrimary
		
		tf.textAlignment = .center
		
		tf.setLineDistance(0)
		tf.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		
		
		self.titleTf = tf
		
		self.eventTypePicker = UIButton(); view.addSubview(eventTypePicker)
		eventTypePicker.translatesAutoresizingMaskIntoConstraints = false
		eventTypePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		eventTypePicker.topAnchor.constraint(equalTo: tf.bottomAnchor, constant: .mPadding/2).isActive = true
		eventTypePicker.setTitleColor(.robinBlue, for: .normal)
		eventTypePicker.addTarget(self, action: #selector(updateEventType), for: .touchUpInside)
		
		
	}
	@objc func updateEventType() {
		
		let configs = Event.EventType.allCases.map { (type) -> ActionConfig in
			return ActionConfig(title: type.rawValue.capitalized, style: .default) {
				self.proposedEvent.type = type
				self.proposedEvent.color = nil
				self.proposedEvent.colors = nil
				self.proposedEvent.frequency = nil
				if type == .strobe {
					self.proposedEvent.frequency = 250
				}
 				self.populateViews()
				
				
			}
		}
		
		
		self.alerts.showActionSheet(withTitle: "What type of event do you want?", andDetail: nil, configs: configs)
	}
	
	
	func initPreviewBox() {
		preview = UIView(); view.addSubview(preview)
		preview.translatesAutoresizingMaskIntoConstraints = false
		preview.topAnchor.constraint(equalTo: eventTypePicker.bottomAnchor, constant: 2.5 * .padding).isActive = true
		preview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		preview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
		preview.heightAnchor.constraint(equalTo: preview.widthAnchor).isActive = true
		
		preview.addBorder(colored: .robinBlack, thickness: 5)
		
		let runAnimation = UIButton(); view.addSubview(runAnimation)
		runAnimation.translatesAutoresizingMaskIntoConstraints = false
		runAnimation.centerXAnchor.constraint(equalTo: preview.centerXAnchor).isActive = true
		runAnimation.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: .mPadding).isActive = true
		
		runAnimation.setTitleColor(.robinPrimary, for: .normal)
		runAnimation.setTitle("Restart Animation", for: .normal)
		runAnimation.addTarget(self, action: #selector(simulate), for: .touchUpInside)
		
	}
	func initCoreEventRequirements() {
		let stack = UIStackView(); view.addSubview(stack)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .center
		stack.distribution = .fillEqually
		
		stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		stack.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 3 * .padding).isActive = true
		stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
		
		
		func format(btn: UIButton, label: String, val: TimeInterval) {
			btn.setTitleColor(.robinBlue, for: .normal)
			btn.setTitle("\(label)\n\(val.clockStyleMilli!)", for: .normal)
			btn.titleLabel?.numberOfLines = 0
			btn.titleLabel?.lineBreakMode = .byWordWrapping
			btn.titleLabel?.textAlignment = .center
			btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
		}
		
		self.start = UIButton()
		self.end = UIButton()
		self.durationButton = UIButton()
		
		format(btn: self.start, label: "Start", val: self.proposedEvent.timelineStart)
		format(btn: self.end, label: "End", val: self.proposedEvent.timelineStart + self.proposedEvent.timelineDuration)
		format(btn: durationButton, label: "Duration", val: self.proposedEvent.timelineDuration)
		
		durationButton.setTitleColor(.robinGray, for: .normal)
		durationButton.isUserInteractionEnabled = false
		
		stack.addArrangedSubview(self.start)
		stack.addArrangedSubview(self.end)
		stack.addArrangedSubview(durationButton)
		
		self.start.addTarget(self, action: #selector(sUpdate), for: .touchUpInside)
		self.end.addTarget(self, action: #selector(eUpdate), for: .touchUpInside)
		
		
	}
	@objc func sUpdate(_ sender: UIButton) {
		getTimeInterval(prefill: self.proposedEvent.timelineStart) { (s, e) in
			guard let s = s, e == nil else { self.alerts.displayAlert(titled: .err, withDetail: e, completion: nil); return }
			self.proposedEvent.timelineStart = s
			
			self.populateViews()
		}
	}
	@objc func eUpdate(_ sender: UIButton) {
		getTimeInterval(prefill: self.proposedEvent.timelineEnd) { (end, e) in
			guard let end = end, e == nil else { self.alerts.displayAlert(titled: .err, withDetail: e, completion: nil); return }
			self.proposedEvent.timelineEnd = end
			
			self.populateViews()
		}
	}
	
	func effectLocalHeader() {
		self.effectTypeMarker = UILabel(); view.addSubview(effectTypeMarker)
		effectTypeMarker.translatesAutoresizingMaskIntoConstraints = false
		effectTypeMarker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding).isActive = true
		effectTypeMarker.topAnchor.constraint(equalTo: durationButton.bottomAnchor, constant: .padding).isActive = true
		self.effectTypeMarker.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		
		let line = UIView()
		view.addSubview(line)
		line.translatesAutoresizingMaskIntoConstraints = false
		line.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		line.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		line.topAnchor.constraint(equalTo: effectTypeMarker.bottomAnchor, constant: .mPadding).isActive = true
		line.heightAnchor.constraint(equalToConstant: 2).isActive = true
		line.backgroundColor = .robinBlack
		
		self.table = UITableView(); view.addSubview(self.table)
		self.table.translatesAutoresizingMaskIntoConstraints = false
		self.table.topAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
		self.table.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		self.table.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		self.table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		self.table.dataSource = self
		self.table.delegate = self
		
	}
	
	
	
	
	func getTimeInterval(prefill: TimeInterval?, completion: Response<TimeInterval>?) {
		var prefillText: String? = prefill?.clockStyleMilli

		
		self.alerts.getTextInput(withTitle: "Please enter a timestamp.", andHelp: "Please format as mm:ss.SSS", andPlaceholder: prefillText ?? "01:23.456", placeholderAsText: prefillText != nil, completion: { (s) in
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "mm:ss.SSS"
			
			guard let dateRepr = dateFormatter.date(from: s) else {
				completion?(nil, "You did not format the duration properly")
				return
			}
			let time = dateRepr.timeIntervalSince1970.remainder(dividingBy: .hour)
			completion?(time, nil)
			
		})
	}
	
}

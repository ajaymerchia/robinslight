//
//  EventEditScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import FlexColorPicker
import ARMDevSuite

class EventEditScreen: RobinVC {
    
    // Data
	var deviceNo: Int!
	var routine: Routine!
	var trackHeadLocation: TimeInterval!
	
	var proposedEvent: Event!
    // System
    
    // UI Components
	var navbar: UINavigationBar!
    
	var titleTf: UITextField!
	var eventTypePicker: UIButton!
	
	var preview: UIView!
	var start: UIButton!
	var end: UIButton!
	var durationButton: UIButton!
	
	var effectTypeMarker: UILabel!
	var table: UITableView!
	
	var colorController: DefaultColorPickerViewController?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		if self.proposedEvent == nil {
			generateProposedEvent()
		}
		
        initUI()
    }
    

	
	func generateProposedEvent() {
		let deviceID = self.routine.deviceIDs[deviceNo]
		let deviceEvents = self.routine.deviceTracks[deviceID]!
		
		let end = deviceEvents.sorted().first { (e) -> Bool in
			return e.timelineStart > self.trackHeadLocation
		}?.timelineEnd ?? (self.trackHeadLocation + TimeInterval(RoutineEditorScreen.secondsMajorMarker))
		
		self.proposedEvent = Event(name: "Hold Effect1", type: .hold, start: self.trackHeadLocation, end: end)
	}
	
	@objc func simulate() {
		
	}
	
}

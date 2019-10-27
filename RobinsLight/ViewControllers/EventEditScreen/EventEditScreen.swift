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
	
	var onUpdate: BlankClosure?
	var tmpIdx: Int?
	
//	static var dumbNames = ["PigLIT", "Winnie the Pooh", "Compoohter", "Eeyore Eyesore", "Chana Bhatura"]
//	static var dumbAdjectives = ["Bonky", "Willy-nilly", "Hunny-Lovin", "Everything-Fearing"]
	
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
		
		let defaultDuration = TimeInterval(RoutineEditorScreen.secondsMajorMarker)*2
		
		
		// prefer the trackhead location if available
		if !deviceEvents.sorted().contains(where: { (e) -> Bool in
			return (self.trackHeadLocation..<(self.trackHeadLocation + defaultDuration)).contains(e.timelineStart)
		}) && !deviceEvents.map({ (e) -> Bool in
			return (e.timelineStart...e.timelineEnd).contains(self.trackHeadLocation)
		}).contains(true) {
			self.proposedEvent = Event(name: "fx_\(deviceID.prefix(3))_\(deviceEvents.count)", type: .hold, start: self.trackHeadLocation, end: self.trackHeadLocation + defaultDuration)
			return
		}
		
		var allStartPoints = [TimeInterval(0)]
		deviceEvents.sorted().forEach { (e) in
			allStartPoints.append(e.timelineStart)
		}
		
		var possibleStartPoints = [TimeInterval(0)]
		deviceEvents.sorted().forEach { (e) in
			possibleStartPoints.append(e.timelineEnd)
		}
		
		
		
		var chosenStartPoint: TimeInterval = deviceEvents.sorted().last!.timelineEnd
		
		for i in (0..<allStartPoints.count - 1) {
			let leftBarrier = possibleStartPoints[i]
			let rightBarrier = allStartPoints[i + 1]
			if (leftBarrier..<rightBarrier).contains(possibleStartPoints[i]) {
				continue
			}
			
			
			let start = allStartPoints[i]
			let nextStart = allStartPoints[i + 1]
			if nextStart - start > defaultDuration {
				chosenStartPoint = start
				break
			}
		}
		
		self.proposedEvent = Event(name: "fx_\(deviceID.prefix(3))_\(deviceEvents.count)", type: .hold, start: chosenStartPoint, end: chosenStartPoint + defaultDuration)
	}
	
	@objc func simulate() {
		
	}
	
}

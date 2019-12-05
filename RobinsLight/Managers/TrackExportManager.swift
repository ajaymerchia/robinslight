//
//  TrackExportManager.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/27/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
class TrackExportManager {
	static let gapThreshold: TimeInterval = 250/1000
	
	static func exportTrackToString(for device: Device, in routine: Routine, completion: Response<String>?) {
		guard let deviceEvents = routine.deviceTracks[device.id]?.sorted(), deviceEvents.count > 0 else {
			completion?(nil, "Could not find events for this device")
			return
		}
		
		var exportFile = ""
		
		if let first = deviceEvents.first, first.timelineStart != 0 {
			let buffer = Event(name: "buffer", type: .off, start: 0, end: first.timelineStart)
			exportFile += rlMinFormatFor(e: buffer)
		}
		
		for idx in (0..<deviceEvents.count) {
			
			let curr = deviceEvents[idx]
			
			func writeCurrent() {
				exportFile += rlMinFormatFor(e: curr)
			}
			
			if idx < deviceEvents.count - 1 {
				// check if there's a gap before deviceEvent[idx+1]
				let next = deviceEvents[idx + 1]
				let gap = next.timelineStart - curr.timelineEnd
				
				// TODO: HANDLE OVERLAPS AND GAPS
				if gap < gapThreshold {
					curr.timelineEnd += gap
					writeCurrent()
				} else {
					// if there is, create a new buffer (off) event to fill the gap
					// add to the xport file string
					writeCurrent()
					let buffer = Event(name: "buffer", type: .off, start: curr.timelineEnd, end: next.timelineStart)
					exportFile += rlMinFormatFor(e: buffer)

				}
			} else {
				writeCurrent()
			}
		}
		
		// add the kill sequence
		exportFile += "\(Int(deviceEvents.last!.timelineEnd * 1000)):kill:0:0::"
		
		completion?(exportFile, nil)
	}
	
	static func exportTrackToURL(for device: Device, in routine: Routine, completion: Response<URL>?) {
		exportTrackToString(for: device, in: routine) { (exportFile, err) in
			guard let exportFile = exportFile, err == nil else {
				completion?(nil, err)
				return
			}
			
			let fileName = "\(device.id)_\(routine.title).txt"
			let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)!
			
			do {
				try exportFile.write(to: path, atomically: true, encoding: .utf8)
			} catch {
				completion?(nil, error.localizedDescription)
			}
			
			completion?(path, nil)
			
		}
	}
	
	
	static func rlMinFormatFor(e: Event) -> String {
		let timestamp = "\(Int(e.timelineStart * 1000))"
		let action = e.type.arduinoDescription
		let duration = "\(Int(e.timelineDuration * 1000))"
		let frequency = (e.type == .strobe ? "\(Int(e.frequency!))" : "0")
		var colors = ""
		if let oneColor = e.color {
			guard let radix = oneColor.decimalRadix else {
				fatalError("couldn't convert color to decimal radix")
			}
			colors = "\(Int(radix))"
		} else if let colorArr = e.colors {
			let arr = colorArr.compactMap({ "\(Int($0.decimalRadix!))" })
			colors = arr.joined(separator: ",")
		}
		if colors.count > 0 {
			colors = "\(colors)," // terminating comma for raspberry pi format
		}
		
		return "\([timestamp, action, duration, frequency, colors].joined(separator: ":")):\n"
	}
}

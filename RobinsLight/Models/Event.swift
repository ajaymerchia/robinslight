//
//  Event.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit
import ARMDevSuite

class Event: DataBlob, TimelineObject, Comparable {
	static func < (lhs: Event, rhs: Event) -> Bool {
		return lhs.timelineStart < rhs.timelineStart
	}
	
	static func == (lhs: Event, rhs: Event) -> Bool {
		return lhs.id == rhs.id
	}
	
	func getTimelinePreferredBarColor() -> UIColor? {
		return color ?? colors?.first
	}
	
	enum EventType: String, CaseIterable, Codable {
		case fade = "fade"
		case strobe = "strobe"
		case hold = "hold"
		case off = "off"
	}
	
	static var dbRef: String = "events"
	
	var id: String
	var name: String
	var type: EventType
	var timelineStart: TimeInterval
	var timelineEnd: TimeInterval
	
	var colors: [UIColor]?
	var color: UIColor?
	var frequency: TimeInterval?
	
	var timelineDuration: TimeInterval {
		return self.timelineEnd - self.timelineStart
	}
	var timelineDescription: String {
		"\(name) (\(self.type.rawValue.capitalized))"
	}
	
	init(name: String, type: EventType, start: TimeInterval, end: TimeInterval) {
		self.id = UUID().uuidString
		self.name = name
		self.type = type
		self.timelineStart = start
		self.timelineEnd = end
	}
	
	enum CodingKeys: String, CodingKey {
        case std = "std"
        
        case frequency = "frequency"
        case colors = "colors"
		case color = "color"
    }
	enum StdInfoKeys: String, CodingKey {
		case id = "id"
		case type = "type"
        case duration = "duration"
		case start = "start"
		case name = "name"
	}
	
	func encode(to encoder: Encoder) throws {
		var values = encoder.container(keyedBy: CodingKeys.self)
		var std = values.nestedContainer(keyedBy: StdInfoKeys.self, forKey: .std)
		try std.encode(type, forKey: .type)
		try std.encode(timelineDuration, forKey: .duration)
		try std.encode(timelineStart, forKey: .start)
		try std.encode(name, forKey: .name)
		try std.encode(id, forKey: .id)
		
		if let f = frequency {
			try values.encode(f, forKey: .frequency)
		}
		if let cs = colors?.compactMap({$0.decimalRadix}) {
			try values.encode(cs, forKey: .colors)
		}
		if let c = color {
			try values.encode(c.decimalRadix, forKey: .color)
		}
	}
	
	required init(from decoder: Decoder) throws {
		var values = try decoder.container(keyedBy: CodingKeys.self)
		var std = try values.nestedContainer(keyedBy: StdInfoKeys.self, forKey: .std)
		self.type = try std.decode(EventType.self, forKey: .type)
		self.name = try std.decode(String.self, forKey: .name)
		self.id = try std.decode(String.self, forKey: .id)
		let st = try std.decode(TimeInterval.self, forKey: .start)
		let dur = try std.decode(TimeInterval.self, forKey: .duration)

		self.timelineStart = st
		self.timelineEnd = st + dur
		
		if self.type == .strobe {
			self.frequency = try values.decode(TimeInterval.self, forKey: .frequency)
			let colorReprs = try values.decode([Int].self, forKey: .colors)
			self.colors = colorReprs.map({ (i) -> UIColor in
				return UIColor(hexStr: String(i, radix: 16))
			})
			
			
		} else if self.type == .fade {
			let val = try values.decode([Double].self, forKey: .colors)
			self.colors = val.map({UIColor(hexStr: String(Int($0), radix: 16))})
		} else if self.type == .hold {
			let val = try values.decode(Int.self, forKey: .color)
			print("stored a color")
			print(val)
			self.color = UIColor(hexStr: String(val, radix: 16))
		}
	}
	
	
}

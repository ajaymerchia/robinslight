//
//  Song.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit

class Song: DataBlob, TimelineObject {
	func getTimelinePreferredBarColor() -> UIColor? {
		return nil
	}
	
	
	
	var timelineDuration: TimeInterval {
		return self.duration
	}
	
	var timelineDescription: String {
		var desc = self.commonName
		if let t = self.timelineDuration.friendlyFormat {
			desc = "\(desc) (\(t))"
		}
		return desc
	}
	
	static var dbRef: String = "songMetadata"
	
	static let defaultSampleRate = 44100
	
	var id: String
	var duration: TimeInterval
	var commonName: String
	var url: URL?
	
	init(id: String, commonName: String, duration: TimeInterval, url: URL?) {
		self.id = id
		self.commonName = commonName
		self.duration = duration
		self.url = url
		
		print("Created \(self.commonName) (\(self.duration.friendlyFormat))")
	}
	
}

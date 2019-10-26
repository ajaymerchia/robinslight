//
//  RoutineEditorScreen.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Main - Variable declarations and setup information


import UIKit
import ARMDevSuite
import AVFoundation

class RoutineEditorScreen: RobinVC {
    
	static var secondsToPixels: CGFloat = 10
	static var secondsMajorMarker: CGFloat = 5
	
	/// zoomPixel & majorSeconds from most zoomed out to most zoomedIn
	static var zoomConfigs: [(CGFloat, CGFloat)] = [
		(2, 30),
		(4, 15),
		(8, 10),
		(10, 5),
		(15, 2),
	]
	static var zoomIndex = 2 {
		didSet {
			secondsToPixels = zoomConfigs[zoomIndex].0
			secondsMajorMarker = zoomConfigs[zoomIndex].1
		}
	}
	
    // Data
	var isPlaying: Bool = false
	var routine: Routine!
	var player: AVAudioPlayer?
	var playerTimer: Timer?
		
	var timeBreaks: [TimeInterval] {
		var breaks: [TimeInterval] = [0]
		
		for s in self.routine.songs {
			breaks.append((breaks.last ?? 0) + s.duration)
		}
		print(breaks)
		return breaks
	}
	var currSongIdx: Int?
	var globalTrackOffset: TimeInterval {
		guard let c = self.currSongIdx else { return 0 }
		return timeBreaks[c] + (self.player?.currentTime ?? 0)
	}
    
    // System
    
    // UI Components
	var play: UIBarButtonItem!
	var pause: UIBarButtonItem!
	var table: UITableView!
	var playHead: UIView!
		var playHeadX: NSLayoutConstraint!
	var scrollers: [UIScrollView] {
		return self.table.visibleCells.compactMap({($0 as? TimelineCell)?.scrollView})
	}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		initUI()
        
    }
    
}

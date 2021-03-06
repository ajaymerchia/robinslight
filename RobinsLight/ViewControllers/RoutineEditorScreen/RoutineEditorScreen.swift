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
		(25, 2),
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
	var bufferTimer: Timer?
	
	var timeBreaks: [TimeInterval] {
		var breaks: [TimeInterval] = [0]
		
		for s in self.routine.songs {
			breaks.append((breaks.last ?? 0) + s.duration)
		}
		return breaks
	}
	var scrollViewWidth: CGFloat {
		return RoutineEditorScreen.secondsToPixels * self.routine.songs.map({CGFloat($0.timelineDuration)}).reduce(0, +)
	}
	var currSongIdx: Int?
	var globalTrackOffset: TimeInterval {
		guard let c = self.currSongIdx else { return 0 }
		return timeBreaks[c] + (self.player?.currentTime ?? 0)
	}
	var pendingOffset: CGFloat = 0
	
	// System
	enum AddPurpose {
		case new
		case attach(Device)
	}
	var addDelegatePurpose: AddPurpose!
	
	var isShowingPlayer: Bool = false
	var masterDevices: [Device] = []
	
	// UI Components
	var play: UIBarButtonItem!
	var pause: UIBarButtonItem!
	var table: UITableView!
	var trackIndicator: UILabel!
	var playTrack: UIView!
	var playHead: UIView!
	var playHeadX: NSLayoutConstraint!
	var playHeadDragger: UIPanGestureRecognizer!
	var scrollers: [UIScrollView] {
		return self.table.visibleCells.compactMap({($0 as? TimelineCell)?.scrollView})
	}
	
	var persistentTrackCell = TimelineCell()
	var persistentMusicBar: UIScrollView!
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		PiBluetoothAPI.shared.delegate = self
		initUI()
		
	}
	
}

//
//  RoutineEditorScreen-runtime.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite
import AVFoundation

extension RoutineEditorScreen: AVAudioPlayerDelegate {

	@objc func zoomIn() {
		RoutineEditorScreen.zoomIndex = min(RoutineEditorScreen.zoomConfigs.count - 1, RoutineEditorScreen.zoomIndex + 1)
		updateState()
		
	}
	@objc func zoomOut() {
		RoutineEditorScreen.zoomIndex = max(0, RoutineEditorScreen.zoomIndex - 1)
		updateState()
	}
	func updateState() {
		self.table.reloadData()
		self.playHeadX.constant = 0
		stopRunTime()
	}
	
	@objc func startRunTime() {
		self.isPlaying = true
		self.setNav()
		
		if self.player == nil {
			if self.currSongIdx == nil {
				self.currSongIdx = 0
			}
			let songIdx = self.currSongIdx ?? 0
			let song = self.routine.songs[songIdx]
			
			guard let url = song.url else {
				return
			}
			
			do {
				self.player = try AVAudioPlayer(contentsOf: url)
				self.player?.delegate = self
			} catch {
				self.alerts.displayAlert(titled: .err, withDetail: error.localizedDescription, completion: nil)
			}

		}
		
		guard let p = self.player else {
			return
		}
		let curr = p.deviceCurrentTime
		p.play(atTime: curr)
		
		
		beginPlayheadAnimation()
		
	}
	@objc func stopRunTime() {
		self.isPlaying = false
		self.setNav()
		self.player?.pause()
		stopPlayheadAnimation()
	}
	
	func beginPlayheadAnimation() {
		var animationPrecision: TimeInterval = 0.05
		func setScrollerOffset(xAugment: (CGFloat)->(CGFloat)) {
			self.scrollers.forEach { (scroller) in
				scroller.contentOffset = CGPoint(x: xAugment(scroller.contentOffset.x), y: scroller.contentOffset.y)
			}
		}
		func resetScrollers() {
			// fix the scrollers if they're not adjusted properly			
			// deduct playHead's current location from the offset
			let offsetInSeconds = CGFloat(globalTrackOffset) - self.playHeadX.constant/RoutineEditorScreen.secondsToPixels
			setScrollerOffset { (_) -> (CGFloat) in
				return offsetInSeconds * RoutineEditorScreen.secondsToPixels
			}
		}
		
		
		UIView.animate(withDuration: 0.5) {
			resetScrollers()
		}
		
		
		self.playerTimer = Timer.scheduledTimer(withTimeInterval: animationPrecision, repeats: true, block: { (_) in
			let movement = CGFloat(animationPrecision) * RoutineEditorScreen.secondsToPixels
			if self.playHeadX.constant < self.view.frame.width/2 - .padding {
				// until the playhead gets to the halfway mark, move the playhead
				self.playHeadX.constant += movement
				self.playHead.layoutSubviews()
			}
			UIView.animate(withDuration: 0.5) {
				resetScrollers()
			}
			
			
			

		})
		
		
		
	}
	func stopPlayheadAnimation() {
		self.playerTimer?.invalidate()
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if flag {
			// play the next song
			if let idx = currSongIdx, idx + 1 < self.routine.songs.count {
				self.currSongIdx = idx + 1
				self.player = nil
				self.playerTimer?.invalidate()
				
				startRunTime()
			}
		}
	}
	
	
	

}

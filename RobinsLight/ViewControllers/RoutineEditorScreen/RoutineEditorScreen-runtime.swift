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

extension RoutineEditorScreen: AVAudioPlayerDelegate, UIGestureRecognizerDelegate {

	@objc func zoomIn() {
		RoutineEditorScreen.zoomIndex = min(RoutineEditorScreen.zoomConfigs.count - 1, RoutineEditorScreen.zoomIndex + 1)
		updateState()
		
	}
	@objc func zoomOut() {
		RoutineEditorScreen.zoomIndex = max(0, RoutineEditorScreen.zoomIndex - 1)
		updateState()
	}
	func updateState() {
		self.setNav()
		refreshTrackCell()
		self.table.reloadData()
		self.playHeadX.constant = 0
		stopRunTime()
	}
	
	func buildPlayer() {
		if self.currSongIdx == nil {
			self.currSongIdx = 0
		}
		let songIdx = self.currSongIdx ?? 0
		let song = self.routine.songs[songIdx]
		
		guard let url = song.url else {
			// this is a buffer
			self.player?.stop()
			self.beginPlayheadAnimation()
			
			return
		}
		
		do {
			self.player = try AVAudioPlayer(contentsOf: url)
			self.player?.delegate = self
		} catch {
			self.alerts.displayAlert(titled: .err, withDetail: error.localizedDescription, completion: nil)
		}
	}
	
	@objc func startRunTime() {
		self.isPlaying = true
		self.setNav()
		
		if self.player == nil {
			self.buildPlayer()
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
			return (offsetInSeconds + self.pendingOffset) * RoutineEditorScreen.secondsToPixels
		}
	}
	
	func beginPlayheadAnimation() {
		let animationPrecision: TimeInterval = 0.05
		
		UIView.animate(withDuration: 0.5) {
			self.resetScrollers()
		}
		
		
		self.playerTimer = Timer.scheduledTimer(withTimeInterval: animationPrecision, repeats: true, block: { (_) in
			let movement = CGFloat(animationPrecision) * RoutineEditorScreen.secondsToPixels
			if self.playHeadX.constant < self.view.frame.width/2 - .padding {
				// until the playhead gets to the halfway mark, move the playhead
				self.playHeadX.constant += movement
				self.playHead.layoutSubviews()
			} else {
				UIView.animate(withDuration: 0.5) {
					self.playHeadX.constant = self.view.frame.width/2 - .padding
				}
			}
			UIView.animate(withDuration: 0.5) {
				self.resetScrollers()
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
	
	@objc func processPlayheadDrag(_ sender: UIPanGestureRecognizer) {
		if isPlaying {
			return
		}
		
		let distance = sender.translation(in: self.view).x + 9.6
		let position = sender.location(in: self.playTrack).x
		self.playHeadX.constant = position
				
		let threshold: CGFloat = 0.85
		if position > self.playTrack.frame.width * threshold && distance > 0 {
			// advance the scrollers
			if self.pendingOffset == 0 {
				self.pendingOffset = distance/RoutineEditorScreen.secondsToPixels
			}
			self.pendingOffset += RoutineEditorScreen.secondsMajorMarker
			
			if TimeInterval(self.pendingOffset) + self.globalTrackOffset > self.timeBreaks.last! {
				self.pendingOffset = CGFloat(self.timeBreaks.last! - self.globalTrackOffset)
			}
			UIView.animate(withDuration: 0.25) {
				self.resetScrollers()
			}
			
		} else if position < self.playTrack.frame.width * (1 - threshold) && distance < 0 {
			// advance the scrollers
			if self.pendingOffset == 0 {
				self.pendingOffset = -distance/RoutineEditorScreen.secondsToPixels
			}
			self.pendingOffset -= RoutineEditorScreen.secondsMajorMarker
			
			if TimeInterval(self.pendingOffset) + self.globalTrackOffset < 0 {
				self.pendingOffset = -CGFloat(self.globalTrackOffset)
			}
			
			UIView.animate(withDuration: 0.25) {
				self.resetScrollers()
			}
		}
		
		
		
		
		if sender.state == UIGestureRecognizer.State.ended {
			// calculate unfuck-up-able targetOffset
			let scrollerOffset = self.persistentMusicBar.contentOffset.x
			let playHeadOffset = position
			
			let totalPixelOffset = position + scrollerOffset
			
			let targetPosition = TimeInterval(totalPixelOffset/RoutineEditorScreen.secondsToPixels)

			var selectedIdx: Int!
			for newSongIdx in (0..<self.timeBreaks.count - 1) {
				if (timeBreaks[newSongIdx]..<timeBreaks[newSongIdx + 1]).contains(targetPosition) {
					selectedIdx = newSongIdx
					break
				}
			}
			if selectedIdx == nil {
				// we are at the last second of the app
				stopRunTime()
				return
			}
			self.currSongIdx = selectedIdx
			self.buildPlayer()
			self.player?.currentTime = targetPosition - self.timeBreaks[selectedIdx]
			// reset manual offset

			self.pendingOffset = 0
			// actually update track seek for all channels and refresh views
			UIView.animate(withDuration: 0.25) {
				self.resetScrollers()
			}
			
			
			return

		}
		
		
	}
	
	
	
	

}

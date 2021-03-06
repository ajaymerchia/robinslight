//
//  RoutineEditorScreen-logic.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Logic - Functions relating to the core functionality/value prop of the application.

import Foundation
import UIKit
import ARMDevSuite
import MediaPlayer

extension RoutineEditorScreen: MPMediaPickerControllerDelegate, UIDocumentPickerDelegate {
    
	func copyEvent(e: Event, sourceTrack: Int) {
		self.getAllDevices { (devices, _) in
			guard var devices = devices else {
				self.alerts.displayAlert(titled: .err, withDetail: "Could not load devices list.", completion: nil)
				return
			}
			
			let srcID = self.routine.deviceIDs[sourceTrack]
			
			devices.removeAll { (sourceDevice) -> Bool in
				return sourceDevice.id == srcID
			}
			
			self.alerts.showActionSheet(withTitle: "Which device would you like to copy this track to?", andDetail: nil, configs: devices.map({ (d) -> ActionConfig in
				return ActionConfig(title: d.commonName, style: .default) {
					
					// create the event, add it to the routine, refresh the table, save the routine, open the editor,
					guard let clonedEvent = e.copy() else {
						self.alerts.displayAlert(titled: .err, withDetail: "Could not clone event", completion: nil)
						return
					}
					guard let editorIdx = self.routine.deviceIDs.firstIndex(of: d.id) else {
						self.alerts.displayAlert(titled: .err, withDetail: "Could not find target device index", completion: nil)
						return
					}
					
					let eCount = self.routine.deviceTracks[d.id]?.count ?? 0
					
					clonedEvent.name = "fx_\(d.id.prefix(3))_\(eCount)"
					
					self.routine.deviceTracks[d.id]?.append(clonedEvent)
					
					RobinCache.records(for: Routine.self).store(self.routine) { (err) in
						guard err == nil else {
							self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
							return
						}
						
						self.table.reloadRows(at: [IndexPath(row: editorIdx, section: 1)], with: .automatic)
						
						
						self.performSegue(withIdentifier: "2eventEdit", sender: (editorIdx, eCount))
						
					}
					
					
					
					
				}
			}))
			
		}
		
		
	}
	
	func addEvent(in track: Int) {
		self.performSegue(withIdentifier: "2eventEdit", sender: track)
	}
	
	@objc func addNewAsset() {
		self.addDelegatePurpose = .new
		self.performSegue(withIdentifier: "editor2addDevice", sender: nil)
	}
	
	func editSongPosition(idx: Int) {
		let song = self.routine.songs[idx]
		self.alerts.showActionSheet(withTitle: song.commonName, andDetail: nil, configs: [
			ActionConfig(title: "Remove song", style: .default, callback: {
				self.routine.songs.remove(at: idx)
				self.updateState()
				RobinCache.records(for: Routine.self).store(self.routine, completion: nil)
			}),
			ActionConfig(title: "Move song", style: .default, callback: {
				self.moveSong(atIdx: idx)
			})
		])
	}
	func moveSong(atIdx idx: Int) {
		let alertVC = UIAlertController(title: "Where would you like to move this song?", message: "We'll insert it right after the one you pick", preferredStyle: .alert)
		
		alertVC.addAction(UIAlertAction(title: "[Move to Beginning]", style: .default, handler: { (_) in
			self.routine.songs.move(fromOffsets: IndexSet(integer: idx), toOffset: 0)
			self.updateState()
		}))
		for i in (0..<self.routine.songs.count) {
			if i == idx {
				continue
			}
			let song = self.routine.songs[i]
			alertVC.addAction(UIAlertAction(title: "After \(song.commonName)", style: .default, handler: { (_) in
				self.routine.songs.move(fromOffsets: IndexSet(integer: idx), toOffset: i + 1)
				self.updateState()
			}))
		}
		alertVC.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
		
		self.present(alertVC, animated: true, completion: nil)
	}
	
	func requestNewSong() {
		self.alerts.showActionSheet(withTitle: "Where do you want to add your song from?", andDetail: nil, configs: [
			ActionConfig(title: "Music Library", style: .default, callback: {
				self.loadSongFromLib()
			}),
			ActionConfig(title: "Files", style: .default, callback: {
				self.loadSongFromFile()
			}),
//			ActionConfig(title: "Add a Buffer Segment", style: .default, callback: {
//				self.loadBufferSection()
//			}),
			ActionConfig(title: "Nevermind", style: .cancel, callback: nil)
		])
	}

	func loadSongFromLib() {
		let music = MPMediaPickerController(mediaTypes: MPMediaType.music)
		music.delegate = self
		music.allowsPickingMultipleItems = false
		
		self.present(music, animated: true, completion: nil)
	}
	
	func loadSongFromFile() {
		let docs = UIDocumentPickerViewController(documentTypes: [AVFileType.m4a.rawValue, AVFileType.mp3.rawValue], in: .import)
		docs.allowsMultipleSelection = false
		docs.delegate = self
		
		self.present(docs, animated: true, completion: nil)
	}
	
	func loadBufferSection() {
		self.alerts.getTextInput(withTitle: "How long a buffer do you want?", andHelp: "Please format as mm:ss.SSS", andPlaceholder: "00:10.32", completion: { (s) in
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "mm:ss.SSS"
			
			guard let dateRepr = dateFormatter.date(from: s) else {
				self.processNewSong(song: nil, err: "You did not format the duration properly")
				return
			}
			let time = dateRepr.timeIntervalSince1970.remainder(dividingBy: .hour)
			
			self.processNewSong(song: Song(id: UUID().uuidString, commonName: "Buffer", duration: time, url: nil), err: nil)
			
		})
	}
	
	func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
		mediaPicker.dismiss(animated: true, completion: nil)
		guard let mediaItem = mediaItemCollection.items.first else { processNewSong(song: nil, err: "no items selected");  return }
		guard let url = mediaItem.assetURL else { processNewSong(song: nil, err: "no url for asset available"); return }
		let id = "\(mediaItem.persistentID)"
		let duration = mediaItem.playbackDuration
		
		guard let name = mediaItem.title else {
			self.nameSegment(id: id, duration: duration, url: url, proposedName: nil)
			return
		}
		
		let song = Song(id: id, commonName: name, duration: duration, url: url)
		processNewSong(song: song, err: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		controller.dismiss(animated: true, completion: nil)
		guard let audioFileURL = urls.first else { processNewSong(song: nil, err: "no items selected"); return }
		do {
			let audioFile = try AVAudioFile(forReading: audioFileURL)
			// Store the audio file locally so it can be used after quitting.
			let trueURL = try SongFileStore.shared.storeFileFrom(url: audioFileURL)
			
			
			let duration = TimeInterval(Int(audioFile.length)/Song.defaultSampleRate)
			
			let name = audioFileURL.deletingPathExtension().lastPathComponent
			nameSegment(id: UUID().uuidString, duration: duration, url: trueURL, proposedName: name)
		} catch {
			processNewSong(song: nil, err: error.localizedDescription)
		}
	}
	
	func nameSegment(id: String, duration: TimeInterval, url: URL?, proposedName: String?) {
		self.alerts.getTextInput(withTitle: "Please provide a name for this file", andHelp: nil, andPlaceholder: proposedName ?? "Song name", placeholderAsText: proposedName != nil, completion: { (name) in
			guard name != "" else {
				self.processNewSong(song: nil, err: "no name for media item selected");
				return
			}
			let song = Song(id: id, commonName: name, duration: duration, url: url)
			self.processNewSong(song: song, err: nil)
		})
	}
	
	
	
	func processNewSong(song: Song?, err: RobinError?) {
		guard let song = song, err == nil else {
			self.alerts.displayAlert(titled: .err, withDetail: err, completion: nil)
			return
		}
		
		func addSong(at idx: Int) {
			// Store Song Data to DB by adding it to the routine and storing the routine
			self.routine.songs.insert(song, at: idx)
			RobinCache.records(for: Routine.self).store(self.routine) { (err) in
				print("finished storing")
			}
			// update view state
			self.updateState()
		}
		
		// clarify where to add it
		if self.routine.songs.count > 0 {
			let alertVC = UIAlertController(title: "Where would you like to insert this song?", message: "We'll insert it right after the one you pick", preferredStyle: .alert)
			
			alertVC.addAction(UIAlertAction(title: "[Add to Beginning]", style: .default, handler: { (_) in
				addSong(at: 0)
			}))
			for i in (0..<self.routine.songs.count) {
				let song = self.routine.songs[i]
				alertVC.addAction(UIAlertAction(title: "After \(song.commonName)", style: .default, handler: { (_) in
					addSong(at: i+1)
				}))
			}
			alertVC.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
			
			self.present(alertVC, animated: true, completion: nil)
			
		} else {
			addSong(at: 0)
		}
		
	}
	

}


extension RoutineEditorScreen {
	
}

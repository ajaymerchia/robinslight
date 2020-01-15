//
//  SongFileStore.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 1/15/20.
//  Copyright © 2020 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import MediaPlayer
import ARMDevSuite

class SongFileStore {
	static let shared = SongFileStore()
	
	private let songsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].resolvingSymlinksInPath().appendingPathComponent("songs")

	
	init() {
		if !FileManager.default.fileExists(atPath: songsURL.relativePath) {
			do {
				try! FileManager.default.createDirectory(at: songsURL, withIntermediateDirectories: true, attributes: nil)
			} catch {
				print("Could not create directory to store songs in")
			}
			
		}
	}
	
	func storeFileFrom(url: URL) throws -> URL {
		let songData = try Data(contentsOf: url)
		var currName = url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if currName == "" {
			currName = LogicSuite.uuid()
		}
		
		let targetURL = songsURL.appendingPathComponent(currName)
		try songData.write(to: targetURL, options: .atomic)
		
		return targetURL
	}
	
	//	func loadFileFrom(urL: URL) {
	//
	//	}
	
}

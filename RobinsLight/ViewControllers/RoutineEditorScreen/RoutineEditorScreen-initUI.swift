//
//  RoutineEditorScreen-initUI.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// UI Initialization - Create the View

import Foundation
import UIKit
import ARMDevSuite

extension RoutineEditorScreen {
    func initUI() {
        buildViews()
        populateViews()
    }
    
    func buildViews() {
        initNav()
		initTable()
		initPlayhead()
    }
    
    func populateViews() {
        
    }

    // UI Initialization Helpers
	func initNav() {
		self.title = self.routine.title
		
		self.play = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startRunTime))
		self.pause = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(stopRunTime))
		
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		
		
		
		setNav()
	}
	func setNav() {
		let hasSongs = self.routine.songs.count > 0
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportDeviceTrack)),
			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAsset)),
			hasSongs ? UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), style: .done, target: self, action: #selector(zoomIn)) : nil,
			hasSongs ? UIBarButtonItem(image: UIImage(systemName: "minus.magnifyingglass"), style: .done, target: self, action: #selector(zoomOut)) : nil,
			hasSongs ? (self.isPlaying ? self.pause : self.play) : nil
		].compactMap({$0})
	}
	func initTable() {
		self.table = UITableView(); view.addSubview(table)
		table.pinSafeTo(self.view)
		table.dataSource = self
		table.delegate = self
//		table.allowsSelection = false
		table.contentInset = UIEdgeInsets(top: 2.5 * .padding, left: 0, bottom: 0, right: 0)
		table.delaysContentTouches = false
		table.register(TimelineCell.self, forCellReuseIdentifier: TimelineCell.kID)
		
		self.persistentTrackCell.awakeFromNib()
		self.persistentTrackCell.editorIdx = -1
		self.persistentTrackCell.delegate = self
		refreshTrackCell()
		
	}
	func refreshTrackCell() {
		self.persistentTrackCell.initFrom(timelineComponents: self.routine.songs, totalLength: self.scrollViewWidth)
		self.persistentTrackCell.trackTitle = "Music Track"
		if self.persistentTrackCell.trackTitleView != nil {
			self.persistentTrackCell.trackTitleView.isUserInteractionEnabled = false
		}
		self.persistentMusicBar = self.persistentTrackCell.scrollView
	}

	func initPlayhead() {
		let playBack = UIView(); view.addSubview(playBack)
		playBack.translatesAutoresizingMaskIntoConstraints = false
		playBack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
		playBack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		playBack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		playBack.heightAnchor.constraint(equalToConstant: 2 * .padding).isActive = true
		playBack.backgroundColor = UIColor.white.withAlphaComponent(0.85)
		
		playTrack = UIView(); view.addSubview(playTrack)
		playTrack.translatesAutoresizingMaskIntoConstraints = false
		playTrack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: .padding).isActive = true
		playTrack.heightAnchor.constraint(equalToConstant: 3).isActive = true
		playTrack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		playTrack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: .padding).isActive = true
		
		playTrack.backgroundColor = .robinDarkGray
		
		let playHeadSize: CGFloat = 30
		self.playHead = UIView(); view.addSubview(playHead)
		playHead.translatesAutoresizingMaskIntoConstraints = false
		playHead.centerYAnchor.constraint(equalTo: playTrack.centerYAnchor).isActive = true
		playHeadX = playHead.centerXAnchor.constraint(equalTo: playTrack.leadingAnchor)
		playHeadX.isActive = true
		
		playHead.heightAnchor.constraint(equalToConstant: playHeadSize).isActive = true
		playHead.widthAnchor.constraint(equalToConstant: playHeadSize).isActive = true
		
		playHead.backgroundColor = .robinPrimary
		playHead.clipsToBounds = true
		playHead.layer.cornerRadius = playHeadSize/2
		
		
		self.playHeadDragger = UIPanGestureRecognizer(target: self, action: #selector(processPlayheadDrag(_:)))
		self.playHeadDragger.delegate = self
		self.playHead.addGestureRecognizer(self.playHeadDragger)
		
		let playHeadMarker = UIView(); view.addSubview(playHeadMarker)
		playHeadMarker.translatesAutoresizingMaskIntoConstraints = false
		playHeadMarker.centerXAnchor.constraint(equalTo: playHead.centerXAnchor).isActive = true
		playHeadMarker.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		playHeadMarker.topAnchor.constraint(equalTo: playHead.bottomAnchor).isActive = true
		playHeadMarker.widthAnchor.constraint(equalToConstant: 2).isActive = true
		playHeadMarker.backgroundColor = .robinPrimary
		
		self.trackIndicator = UILabel(); view.addSubview(trackIndicator)
			self.trackIndicator.translatesAutoresizingMaskIntoConstraints = false
			self.trackIndicator.topAnchor.constraint(equalTo: playHead.bottomAnchor, constant: 0).isActive = true
			self.trackIndicator.leadingAnchor.constraint(equalTo: playHeadMarker.trailingAnchor, constant: .mPadding/2).isActive = true
		self.trackIndicator.textColor = .robinPrimary
		self.trackIndicator.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
		self.trackIndicator.text = "0:00"
			
		
	}
	
}

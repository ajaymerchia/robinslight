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
		
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAsset)),
			UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), style: .done, target: self, action: #selector(zoomIn)),
			UIBarButtonItem(image: UIImage(systemName: "minus.magnifyingglass"), style: .done, target: self, action: #selector(zoomOut)),
			self.isPlaying ? self.pause : self.play
		]
	}
	func initTable() {
		self.table = UITableView(); view.addSubview(table)
		table.pinSafeTo(self.view)
		table.dataSource = self
		table.delegate = self
//		table.allowsSelection = false
		table.contentInset = UIEdgeInsets(top: 2 * .padding, left: 0, bottom: 0, right: 0)
		table.delaysContentTouches = false
		table.register(TimelineCell.self, forCellReuseIdentifier: TimelineCell.kID)
		
		
	}

	func initPlayhead() {
		let playBack = UIView(); view.addSubview(playBack)
		playBack.translatesAutoresizingMaskIntoConstraints = false
		playBack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
		playBack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		playBack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		playBack.heightAnchor.constraint(equalToConstant: 2 * .padding).isActive = true
		playBack.backgroundColor = UIColor.white.withAlphaComponent(0.85)
		
		let playTrack = UIView(); view.addSubview(playTrack)
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
		
		let playHeadMarker = UIView(); view.addSubview(playHeadMarker)
		playHeadMarker.translatesAutoresizingMaskIntoConstraints = false
		playHeadMarker.centerXAnchor.constraint(equalTo: playHead.centerXAnchor).isActive = true
		playHeadMarker.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		playHeadMarker.topAnchor.constraint(equalTo: playHead.bottomAnchor).isActive = true
		playHeadMarker.widthAnchor.constraint(equalToConstant: 2).isActive = true
		playHeadMarker.backgroundColor = .robinPrimary
		
	}
	
}

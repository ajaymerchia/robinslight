//
//  SongManagerCell.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import UIKit

protocol TimelineObject {
	var timelineDuration: TimeInterval { get }
	var timelineDescription: String { get }
	func getTimelinePreferredBarColor() -> UIColor?
}

protocol TimelineCellDelegate {
	func didSelectTimelineBar(_ cell: TimelineCell, at idx: Int)
	func didSelectAddButton(_ cell: TimelineCell)
	func didSelectDeleteButton(_ cell: TimelineCell)
	func didSelectTimelineTitle(_ cell: TimelineCell)
}

class TimelineCell: UITableViewCell {
	static var kID = "timelineCell"
	
	var editorIdx: Int!
	var trackTitle: String! {
		didSet {
			if trackTitleView != nil {
				if self.trackTitle != "" {
					trackTitleView.setTitle(self.trackTitle, for: .normal)
					trackTitleView.alpha = 1
				} else {
					trackTitleView.alpha = 0
				}
			}
		}
	}
	var additionalInfo: String! {
		didSet {
			if trackTitleView != nil {
				if self.additionalInfo != "" {
					additionalInfoLabel.text = self.additionalInfo
					additionalInfoLabel.alpha = 1
				} else {
					additionalInfoLabel.alpha = 0
				}
			}
		}
	}
	
	var timelineEvents: [TimelineObject]!
	
	var addLabel: UILabel!
	var addButton: UIButton!
	var scrollView: UIScrollView?
	var trackTitleView: UIButton!
	var additionalInfoLabel: UILabel!
	
	var delegate: TimelineCellDelegate?
	
	var isDeviceTrack: Bool = true
	
	var totalLength: CGFloat!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
	}
	func initFrom(timelineComponents: [TimelineObject], isDeviceTrack: Bool = false, totalLength: CGFloat) {
		self.timelineEvents = timelineComponents
		self.isDeviceTrack = isDeviceTrack
		self.totalLength = totalLength
		self.contentView.clearContents()
		
		if timelineComponents.count == 0 && !isDeviceTrack {
			buildEventAdder()
		} else {
			buildEventViewer()
		}
	}
	
	func addTicks() {
		guard let scrollView = self.scrollView else { return }
		
		for majorTick in stride(from: RoutineEditorScreen.secondsMajorMarker, to: self.totalLength, by: RoutineEditorScreen.secondsMajorMarker) {
			let majorTickPix = majorTick * RoutineEditorScreen.secondsToPixels
			
			let lineHeight: CGFloat = 10
			let line = UIView(); scrollView.addSubview(line)
			line.translatesAutoresizingMaskIntoConstraints = false
			line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			line.heightAnchor.constraint(equalToConstant: lineHeight).isActive = true
			line.widthAnchor.constraint(equalToConstant: 2).isActive = true
			line.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: majorTickPix).isActive = true
			
			line.backgroundColor = .robinBlack
			
			let timeLabel = UILabel(); scrollView.addSubview(timeLabel)
			timeLabel.translatesAutoresizingMaskIntoConstraints = false
			timeLabel.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -2).isActive = true
			timeLabel.centerXAnchor.constraint(equalTo: line.centerXAnchor).isActive = true
			timeLabel.text = TimeInterval(majorTick).clockStyle
			timeLabel.textColor = .robinBlack
			timeLabel.font = UIFont.systemFont(ofSize: 10, weight: .light)
			
		}
	}
	
	func buildEventViewer() {
		self.scrollView = UIScrollView();
		guard let scrollView = self.scrollView else { return }
		contentView.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .padding).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mPadding).isActive = true
		scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		
		scrollView.layoutSubviews()
		scrollView.contentSize = CGSize(width: self.totalLength, height: scrollView.frame.height)
		scrollView.showsHorizontalScrollIndicator = false
		
		scrollView.clipsToBounds = true
		
		func rowHeader() {
			trackTitleView = UIButton(); contentView.addSubview(trackTitleView)
			trackTitleView.translatesAutoresizingMaskIntoConstraints = false
			trackTitleView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: .padding).isActive = true
			trackTitleView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: .mPadding).isActive = true
			trackTitleView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3).isActive = true
			
			contentView.layoutSubviews()
			let headerHeight = trackTitleView.frame.height
			trackTitleView.layoutSubviews()
			trackTitleView.heightAnchor.constraint(equalToConstant: trackTitleView.frame.height).isActive = true
			
			scrollView.topAnchor.constraint(equalTo: trackTitleView.bottomAnchor, constant: .mPadding).isActive = true
			
			trackTitleView.setBackgroundColor(color: UIColor.robinBlue.withAlphaComponent(0.7), forState: .normal)
			trackTitleView.layer.cornerRadius = 10
			trackTitleView.clipsToBounds = true
			trackTitleView.alpha = 0
			trackTitleView.titleLabel?.adjustsFontSizeToFitWidth = true
			trackTitleView.addTarget(self, action: #selector(forwardTrackTitleTap), for: .touchUpInside)
			
			
			let buttonSize: CGFloat = headerHeight
			let adder = UIButton(); contentView.addSubview(adder)
			adder.translatesAutoresizingMaskIntoConstraints = false
			adder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.padding).isActive = true
			adder.centerYAnchor.constraint(equalTo: trackTitleView.centerYAnchor).isActive = true
			adder.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
			adder.heightAnchor.constraint(equalTo: adder.widthAnchor).isActive = true
			
			adder.setBackgroundImage(UIImage(systemName: "plus.circle.fill")?.withTintColor(.systemGreen).withRenderingMode(.alwaysOriginal), for: .normal)
			adder.imageView?.tintColor = .systemGreen
			adder.tintColor = .systemGreen
			adder.addTarget(self, action: #selector(performAddAction), for: .touchUpInside)
			
			adder.contentMode = .scaleAspectFill
			
			if self.isDeviceTrack {
				let deleter = UIButton(); contentView.addSubview(deleter)
				deleter.translatesAutoresizingMaskIntoConstraints = false
				deleter.trailingAnchor.constraint(equalTo: adder.leadingAnchor, constant: -.mPadding).isActive = true
				deleter.centerYAnchor.constraint(equalTo: adder.centerYAnchor).isActive = true
				deleter.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
				deleter.heightAnchor.constraint(equalTo: deleter.widthAnchor).isActive = true
				
				deleter.setBackgroundImage(UIImage(systemName: "x.circle.fill")?.withTintColor(.robinRed).withRenderingMode(.alwaysOriginal), for: .normal)
				deleter.imageView?.tintColor = .robinRed
				deleter.tintColor = .robinRed
				deleter.addTarget(self, action: #selector(performDeleteAction), for: .touchUpInside)
				
				deleter.contentMode = .scaleAspectFill
				
				additionalInfoLabel = UILabel(); contentView.addSubview(additionalInfoLabel)
				additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
				additionalInfoLabel.leadingAnchor.constraint(equalTo: trackTitleView.trailingAnchor, constant: .mPadding).isActive = true
				additionalInfoLabel.centerYAnchor.constraint(equalTo: trackTitleView.centerYAnchor).isActive = true
				additionalInfoLabel.trailingAnchor.constraint(equalTo: deleter.leadingAnchor, constant: -.mPadding).isActive = true
				
				additionalInfoLabel.textColor = UIColor.robinBlack
				additionalInfoLabel.alpha = 0
				additionalInfoLabel.adjustsFontSizeToFitWidth = true
			}
			
		}
		rowHeader()
		
		addTicks()
		
		var prevLeftAnchor = scrollView.leadingAnchor
		var firstAnchor: NSLayoutXAxisAnchor!
		var lastAnchor: NSLayoutXAxisAnchor!
		var bottomAnchor: NSLayoutYAxisAnchor!
		
		var totalTrackPixels: CGFloat = 0
		
		for eventIdx in (0..<timelineEvents.count) {
			let event = timelineEvents[eventIdx]
			let songBar = UIButton(); scrollView.addSubview(songBar)
			
			let size = CGFloat(event.timelineDuration) * RoutineEditorScreen.secondsToPixels
			totalTrackPixels += size
			
			songBar.translatesAutoresizingMaskIntoConstraints = false
			if let fx = event as? Event {
				songBar.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(fx.timelineStart) * RoutineEditorScreen.secondsToPixels).isActive = true
			} else {
				songBar.leadingAnchor.constraint(equalTo: prevLeftAnchor).isActive = true
			}
			
			songBar.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1).isActive = true
			songBar.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
			songBar.widthAnchor.constraint(equalToConstant: size).isActive = true
			
			if eventIdx == 0 {
				firstAnchor = songBar.leadingAnchor
			}
			
			let songLabel = UILabel(); songBar.addSubview(songLabel)
			songLabel.translatesAutoresizingMaskIntoConstraints = false
			songLabel.leadingAnchor.constraint(equalTo: songBar.leadingAnchor, constant: .mPadding).isActive = true
			songLabel.topAnchor.constraint(equalTo: songBar.topAnchor, constant: .mPadding).isActive = true
			songLabel.trailingAnchor.constraint(equalTo: songBar.trailingAnchor, constant: -.mPadding)
			songLabel.font = UIFont.systemFont(ofSize: 9, weight: .black)
			songLabel.text = event.timelineDescription
			
			
			
			
			prevLeftAnchor = songBar.trailingAnchor
			
			let color = event.getTimelinePreferredBarColor() ?? UIColor.themeColors[eventIdx % UIColor.themeColors.count]
			
			songBar.setBackgroundColor(color: color.withAlphaComponent(0.4), forState: .normal)
			songBar.setBackgroundColor(color: color.withAlphaComponent(0.6), forState: .highlighted)
			songLabel.textColor = color.modified(withAdditionalHue: 0, additionalSaturation: 0, additionalBrightness: -0.3)
			
			songBar.layer.cornerRadius = 10
			songBar.clipsToBounds = true
			songBar.tag = eventIdx
			songBar.addTarget(self, action: #selector(tappedTimelineBar), for: .touchUpInside)
			
			if eventIdx == timelineEvents.count - 1 {
				lastAnchor = songBar.trailingAnchor
				bottomAnchor = songBar.bottomAnchor
			}
			
			
		}
		
		
		
		
		
		
	}
	
	func buildEventAdder() {
		let container = UIView(); contentView.addSubview(container)
		container.center(in: self.contentView)
		container.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
		
		addLabel = UILabel(); container.addSubview(addLabel)
		addLabel.translatesAutoresizingMaskIntoConstraints = false
		addLabel.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
		addLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		addLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
		addLabel.textColor = .robinDarkGray
		addLabel.text = "You need a song to compose the lights for a routine."
		
		
		let buttHeight: CGFloat = 30
		addButton = UIButton(); container.addSubview(addButton)
		addButton.translatesAutoresizingMaskIntoConstraints = false
		addButton.topAnchor.constraint(equalTo: addLabel.bottomAnchor, constant: .mPadding).isActive = true
		addButton.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
		addButton.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		addButton.heightAnchor.constraint(equalToConstant: buttHeight).isActive = true
		addButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
		
		addButton.setTitle("Pick a Song!", for: .normal)
		addButton.setBackgroundColor(color: .robinPrimary, forState: .normal)
		addButton.setTitleColor(.white, for: .normal)
		addButton.clipsToBounds = true
		addButton.layer.cornerRadius = buttHeight/2
		
		addButton.addTarget(self, action: #selector(performAddAction), for: .touchUpInside)
		addButton.isUserInteractionEnabled = true
		addButton.showsTouchWhenHighlighted = true
	}
	
	@objc func performAddAction() {
		delegate?.didSelectAddButton(self)
	}
	
	@objc func tappedTimelineBar(_ bar: UIButton) {
		delegate?.didSelectTimelineBar(self, at: bar.tag)
	}
	@objc func performDeleteAction() {
		delegate?.didSelectDeleteButton(self)
	}
	@objc func forwardTrackTitleTap() {
		delegate?.didSelectTimelineTitle(self)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
		// Configure the view for the selected state
	}
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
	}
	
}

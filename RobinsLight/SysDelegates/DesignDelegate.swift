//
//  DesignDelegate.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit
import ARMDevSuite

class Design {
	static func configDesign() {
		UIView.appearance().tintColor = .robinPrimary
		configureProgressHudAppearance()
		configureNavAppearance()
	}
	static func configureProgressHudAppearance() {
        var config = ARMBubbleProgressHudDefaultConfiguration()
		config.bubbleStyle = ARMBubbleProgressHudBubbleStyle.filled
		config.animationStyle = .blinking
        config.backgroundAlpha = 0.9
		config.colorPrimary = .robinPrimary
		config.colorSecondary = .robinSecondary
		config.bubbleGap = false
        
        ARMBubbleProgressHud.defaultStyle = config
    }
    
    static func configureNavAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.robinPrimary
    }
}

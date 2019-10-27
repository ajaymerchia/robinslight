//
//  UIAttributes.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import ARMDevSuite

extension CGFloat {
	static let padding: CGFloat = 20
	static let mPadding: CGFloat = 8
}

extension UIColor {
	convenience init(hexStr hex: String) {
		guard let rgb = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else {
			fatalError("Invalid hex string \"\(hex)\"")
		}
		let red = CGFloat((rgb >> 16) & 0xFF)/255
		let green = CGFloat((rgb >> 8) & 0xFF)/255
		let blue = CGFloat(rgb & 0xFF)/255
		
		self.init([red, green, blue, 1])
	}
	
	
	static var robinPrimary: UIColor {
		return robinRed
	}
	static var robinSecondary: UIColor {
		return robinPurple
	}
	
	var decimalRadix: Double? {
		guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

		let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
		
		let composite = Double(r << 16) + Double(g << 8) + Double(b)
		
		return composite
	}

	var hexString: String? {
		if let decRad = self.decimalRadix {
			return String(Int(decRad), radix: 16)
		}
		return nil
	}

	var hsba:(h: CGFloat, s: CGFloat,b: CGFloat,a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }
	
	// Theme
	/// F74762
	static let robinRed 		= UIColor(hexStr: "F74762")
	/// D55EA3
	static let robinMaroon 		= UIColor(hexStr: "D55EA3")
	/// CD5DCA
	static let robinPurple		= UIColor(hexStr: "CD5DCA")
	/// 9688DB
	static let robinLavender 	= UIColor(hexStr: "9688DB")
	/// 67BCEB
	static let robinBlue	 	= UIColor(hexStr: "67BCEB")
	
	static let themeColors: [UIColor] = [.robinRed, .robinMaroon, .robinPurple, .robinLavender, .robinBlue]
	
	
	
	// Monotone
	/// 444444
	static let robinBlack		= UIColor(hexStr: "444444")
	/// 999999
	static let robinDarkGray	= UIColor(hexStr: "999999")
	/// cccccc
	static let robinGray		= UIColor(hexStr: "cccccc")
	/// eeeeee
	static let robinLightGray	= UIColor(hexStr: "eeeeee")
	/// f7f7f7
	static let robinOffWhite	= UIColor(hexStr: "f7f7f7")
	
	

}



//extension LinearGradient {
//	static let themeGradient = LinearGradient(gradient: Gradient(colors: [.robinRed, .robinMaroon, .robinPurple, .robinLavender, .robinBlue]), startPoint: .bottomLeading, endPoint: .topTrailing)
//}

extension UIEdgeInsets {
	init(padding: CGFloat) {
		self.init(top: padding, left: padding, bottom: padding, right: padding)
	}
}

extension UIView {
	func pinSafeTo(_ other: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
		self.centerXAnchor.constraint(equalTo: other.safeAreaLayoutGuide.centerXAnchor).isActive = true
		self.centerYAnchor.constraint(equalTo: other.safeAreaLayoutGuide.centerYAnchor).isActive = true
		self.widthAnchor.constraint(equalTo: other.safeAreaLayoutGuide.widthAnchor).isActive = true
		self.heightAnchor.constraint(equalTo: other.safeAreaLayoutGuide.heightAnchor).isActive = true
        
    }
	
	func clearContents() {
		self.subviews.forEach({$0.removeFromSuperview()})
	}
}

extension String {
	static let err: String = "Ruh-roh!"
}

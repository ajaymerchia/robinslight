//
//  Utils.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import CryptoKit


typealias BlankClosure = ()->()
typealias RobinError = String
typealias ErrorReturn = (_ error: RobinError?) -> ()
typealias Response<T> = (T?, _ error: RobinError?) -> ()

extension Encodable {
	var prettyJSONRepr: String {
		let err = "[UNABLE TO PRODUCE JSON]"
		let en = JSONEncoder()
		en.outputFormatting = .prettyPrinted
		do {
			let data = try en.encode(self)
			return String(data: data, encoding: .utf8) ?? err
		} catch {
			return err
		}
	}
}

extension Timer {
	static func fire(after time: TimeInterval, completion: BlankClosure?) {
		Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (_) in
			completion?()
		}
	}
}

extension Color {

    var hexRepresentation: String? {
        let children = Mirror(reflecting: self).children
        let _provider = children.filter { $0.label == "provider" }.first
        guard let provider = _provider?.value else {
            return nil
        }
        let providerChildren = Mirror(reflecting: provider).children
        let _base = providerChildren.filter { $0.label == "base" }.first
        guard let base = _base?.value else {
            return nil
        }
        var baseValue: String = ""
        dump(base, to: &baseValue)
        guard let firstLine = baseValue.split(separator: "\n").first,
              let hexString = firstLine.split(separator: " ")[1] as Substring? else {
            return nil
        }
        return hexString.trimmingCharacters(in: .newlines)
    }
	
	
	var uiColor: UIColor? {
		guard let hex = self.hexRepresentation else { return nil }
		return UIColor(hex: hex)
	}
	

}

extension UIColor {
	convenience init(hex: String) {
		guard let rgb = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else {
			fatalError("Invalid hex string \"\(hex)\"")
		}
		
		
		self.init(
			red: CGFloat((rgb >> 24) & 0xFF)/255,
			green: CGFloat((rgb >> 16) & 0xFF)/255,
			blue: CGFloat((rgb >> 8) & 0xFF)/255,
			alpha: 1
		)
	}
}


extension TimeInterval {
    static let second: TimeInterval = 1
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = TimeInterval.minute * 60
    static let day: TimeInterval = TimeInterval.hour * 24
    static let week: TimeInterval = TimeInterval.day * 7
    static let month: TimeInterval = TimeInterval.day * 30
    static let year: TimeInterval = TimeInterval.day * 365
}

extension DispatchGroup {
	convenience init(count: Int) {
		self.init()
		(0..<count).forEach { (_) in
			self.enter()
		}
	}
	
	convenience init<T: Collection>(vals: T, forEach: (T.Element, DispatchGroup)->()) {
		self.init()
		
		(0..<vals.count).forEach { (_) in
			self.enter()
		}
		vals.forEach { (elem) in
			forEach(elem, self)
		}
	}
	
}


extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}

extension Data {
	var sha256: String {
		return SHA256.hash(data: self).hexStr
	}
}

extension Array {
    func chunked(into size:Int) -> [[Element]] {
        
        var chunkedArray = [[Element]]()
        
        for index in 0...self.count {
            if index % size == 0 && index != 0 {
                chunkedArray.append(Array(self[(index - size)..<index]))
            } else if(index == self.count) {
                chunkedArray.append(Array(self[index - 1..<index]))
            }
        }
        
        return chunkedArray
    }
}

extension TimeInterval {
	var friendlyFormat: String? {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
		formatter.allowedUnits = NSCalendar.Unit(rawValue: NSCalendar.Unit.hour.rawValue | NSCalendar.Unit.minute.rawValue | NSCalendar.Unit.second.rawValue)

		let now = Date()
		let pickedDate = now.addingTimeInterval(self)
		return formatter.string(from: now, to: pickedDate)
	}
	
	var clockStyle: String? {
		let minutes = Int(floor(self/60))
		let seconds = Int(floor(self)) % 60
		return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
	}
	var clockStyleMilli: String? {
		let minutes = Int(floor(self/60))
		let seconds = self.remainder(dividingBy: 60)
		
		let nbrfrmt = NumberFormatter()
		nbrfrmt.maximumIntegerDigits = 2
		nbrfrmt.minimumIntegerDigits = 2
		nbrfrmt.maximumFractionDigits = 3
		nbrfrmt.minimumFractionDigits = 3
		
		
		return "\(minutes):\(nbrfrmt.string(from: NSNumber(value: seconds))!)"
	}
}

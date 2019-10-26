//
//  RobinsCache.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
class RobinCache {
	static let shared = RobinCache()
	private var caches = [String: Any]()
	static let useCaches: Bool = false
	
	static func records<T: DataBlob>(for type: T.Type) -> RobinObjectCache<T> {
		if let cache = shared.caches[type.dbRef] as? RobinObjectCache<T> {
			return cache
		}
		let newCache = RobinObjectCache<T>()
		shared.caches[type.dbRef] = newCache
		return newCache
	}
}

class RobinObjectCache<T: DataBlob> {
	typealias CacheRecord = (T, Date)
	private let expirationDuration: TimeInterval = TimeInterval.minute * 3
	private var records = [String: CacheRecord]()
	
	func store(_ obj: T, completion: ErrorReturn?) {
		self.records[obj.id] = (obj, Date())
		DataStack.store(object: obj, completion: completion)
	}
	
	func getSync(id: String) -> T? {
		if let record = records[id] {
			if Date().timeIntervalSince(record.1) < expirationDuration {
				
			}
			return record.0
		} else {
			return nil
		}
		
	}
	
	func get(id: String, completion: Response<T>?) {
		if RobinCache.useCaches {
			if let record = getSync(id: id) {
				completion?(record, nil)
				return
			}
		} else {
			DataStack.load(type: T.self, id: id) { (blob, err) in
				guard let blob = blob, err == nil else {
					completion?(nil, err)
					return
				}
				
				self.records[id] = (blob, Date())
				completion?(blob, nil)
			}
		}
		
		
		
	}
}

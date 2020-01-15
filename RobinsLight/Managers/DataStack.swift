//
//  DataStack.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation
import UIKit



protocol DataBlob: Codable & Identifiable {
	static var dbRef: String { get set }
	var id: String {get set}
}

extension DataBlob {
	static func genFileName(for id: String) -> String {
		return "\(id).json"
	}
	var fileName: String {
		return "\(id).json"
	}
}



// Usage
class DataStack {
	private static let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].resolvingSymlinksInPath()

	private static func target<T: DataBlob>(entity: T.Type, id: String? = nil) -> URL {
		var entityFolder = documentsURL.appendingPathComponent(entity.dbRef, isDirectory: true)
		print(entityFolder)
		if let id = id {
			return entityFolder.appendingPathComponent(T.genFileName(for: id))
		}
		return entityFolder
	}
	
	static func exists<T: DataBlob>(type: T.Type, id: String) -> Bool {
		return FileManager.default.fileExists(atPath: target(entity: type, id: id).path)
	}
	static func list<T: DataBlob>(type: T.Type, completion: Response<[String]>?) {
		do {
			let entityFolder = target(entity: type)
			
			if !FileManager.default.fileExists(atPath: entityFolder.absoluteString) {
				try! FileManager.default.createDirectory(at: entityFolder, withIntermediateDirectories: true, attributes: nil)
			}
			
			let entities = try FileManager.default.contentsOfDirectory(at: entityFolder, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
			let childPaths = entities.map({$0.deletingPathExtension().lastPathComponent})
			completion?(childPaths, nil)
		} catch {
			completion?(nil, error.localizedDescription)
		}
	}
	
	static func load<T: DataBlob>(type: T.Type, id: String, completion: Response<T>?) {
		let decoder = JSONDecoder()
		do {
			let entityFolder = documentsURL.appendingPathComponent(T.dbRef, isDirectory: true)
			let file = entityFolder.appendingPathComponent(T.genFileName(for: id))
			let jsonData = try Data(contentsOf: file)
			let obj = try? decoder.decode(T.self, from: jsonData)
			if let obj = obj {
				completion?(obj, nil)
			} else {
				delete(type: type, id: id, completion: nil)
			}
		} catch {
			// delete the corrupted file
//			delete(type: type, id: id, completion: nil)
			print("Corrupted File", error.localizedDescription, type.dbRef, id)
			completion?(nil, error.localizedDescription)
		}

	}
	static func delete<T: DataBlob>(type: T.Type, id: String, completion: ErrorReturn?) {
		let target = documentsURL.appendingPathComponent(T.dbRef, isDirectory: true).appendingPathComponent(T.genFileName(for: id))
		do {
			try FileManager.default.removeItem(at: target)
			completion?(nil)
		} catch {
			completion?(error.localizedDescription)
		}
	}
	
	static func store<T: DataBlob>(object: T, completion: ErrorReturn?) {
		let encoder = JSONEncoder()
		do {
			let jsonData = try encoder.encode(object)
			let entityFolder = documentsURL.appendingPathComponent(T.dbRef, isDirectory: true)
			let entityFolderRepr = entityFolder.relativePath
			if ( !FileManager.default.fileExists(atPath: entityFolderRepr) )
			{
				try! FileManager.default.createDirectory(at: entityFolder, withIntermediateDirectories: true, attributes: nil)
			}
			
			let fileLocation = entityFolder.appendingPathComponent(object.fileName, isDirectory: false)
			
			do {
				try jsonData.write(to: fileLocation, options: .atomic)
			} catch {
				completion?(error.localizedDescription)
				return
			}
			completion?(nil)
			
		} catch {
			print(error.localizedDescription)
			completion?(error.localizedDescription)
		}
		
		
	}
	
}


extension FileManager {
	func delete(at url: URL) -> Bool {
		do {
			try self.removeItem(at: url)
			return true
		} catch {
			return false
		}
	}
}


enum StackError: Error {
	case badEncoding
	
}

// MARK: DataBlob Conformance for Special Data Types
class ImageRecord: DataBlob {
	static var dbRef: String = "images"
	
	private enum CodingKeys: CodingKey {
		case img
	}
	
	var img: UIImage? {
		didSet {
			guard let img = img?.jpegData(compressionQuality: 1) else {
				self.id = ""
				return
			}
			
			self.id = img.sha256
		}
	}
	
	var id: String = UUID().uuidString
	
	
	public required init(from decoder: Decoder) throws {
		let jpegData = try decoder.container(keyedBy: CodingKeys.self).decode(Data.self, forKey: .img)
		self.img = UIImage(data: jpegData)
		
	}
	init() {
		
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		guard let jpegData = img?.jpegData(compressionQuality: 1) else {
			// FIXME
			throw StackError.badEncoding
		}
		try container.encode(jpegData, forKey: .img)
	}
}

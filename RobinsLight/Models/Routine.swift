//
//  Routine.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/26/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//

import Foundation

class Routine: DataBlob {

	
	static var dbRef: String = "routines"
	
	var id: String = UUID().uuidString
	var title: String
	
	var songs: [Song] = []
	
	init(title: String) {
		self.title = title
	}
	
	
}

//
//  EventEditScreen-table.swift
//  RobinsLight
//
//  Created by Ajay Merchia on 10/27/19.
//  Copyright © 2019 Mobile Developers of Berkeley. All rights reserved.
//
// Protocol Conformance for EventEditScreen_table

import Foundation
import UIKit
import ARMDevSuite
import FlexColorPicker

extension EventEditScreen: UITableViewDelegate, UITableViewDataSource {
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if self.proposedEvent.type == .strobe {
			return 2
		}
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.proposedEvent.type == .strobe {
			return section == 0 ? 1 : self.proposedEvent.colors?.count ?? 1
		} else if self.proposedEvent.type == .fade {
			return (self.proposedEvent.colors?.count ?? 0) + 1
		} else {
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if self.proposedEvent.type == .strobe {
			return 50
		} else if self.proposedEvent.type == .fade {
			return 50
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.backgroundColor = UIColor.robinPrimary.withAlphaComponent(1)
		let label = UILabel(); view.addSubview(label)
			label.translatesAutoresizingMaskIntoConstraints = false
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .padding).isActive = true
		
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
		
		if self.proposedEvent.type == .strobe {
			label.text = (section == 0 ? "Strobe Frequency" : "Strobe Colors")
			return view
		} else if self.proposedEvent.type == .fade {
			label.text = "Fade Colors"
			return view
		} else {
			return nil
		}
	
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if self.proposedEvent.type == .strobe {
			if indexPath.section == 0 {
				return UITableViewCell()

			} else {
				return UITableViewCell()

			}
		} else if self.proposedEvent.type == .fade {
			if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
				// configure "add one more" cell
				let cell = UITableViewCell(style: .value1, reuseIdentifier: "fadeCellAdd")
				cell.textLabel?.text = "Add another color"

				return cell
			} else {
				// configure a color cell
				let cell = UITableViewCell(style: .value1, reuseIdentifier: "fadeCell")
				cell.textLabel?.text = "Fade Step \(indexPath.row + 1)"
				
				cell.detailTextLabel?.text = "\(self.proposedEvent.colors?[indexPath.row].hexString ?? "") ★"
				cell.detailTextLabel?.textColor = self.proposedEvent.colors?[indexPath.row]
				return cell

			}
			
			

		} else if self.proposedEvent.type == .hold {
			let cell = UITableViewCell(style: .value1, reuseIdentifier: "holdCell")
			cell.textLabel?.text = "Color Held"
			
			cell.detailTextLabel?.text = "\(self.proposedEvent.color?.hexString ?? "") ★"
			cell.detailTextLabel?.textColor = self.proposedEvent.color
			
			return cell
			
		} else {
			return UITableViewCell()
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		if self.proposedEvent.type == .strobe {
			return indexPath.section == 1
		} else if self.proposedEvent.type == .fade {
			return true
		} else if self.proposedEvent.type == .hold {
			return false
		} else {
			return false
		}
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
//	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//		if self.proposedEvent.type == .strobe {
//			return .none
//		} else if self.proposedEvent.type == .fade {
//			return .none
//		} else if self.proposedEvent.type == .hold {
//			return .none
//		} else {
//			return .none
//		}
//	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if self.proposedEvent.type == .strobe {
			return
		} else if self.proposedEvent.type == .fade {
			self.proposedEvent.colors = self.proposedEvent.colors ?? []
			self.proposedEvent.colors?.append(.black)
		} else if self.proposedEvent.type == .hold {
			return
		} else {
			return
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		if self.proposedEvent.type == .strobe {
			if indexPath.section == 0 {
				
			} else {
				
			}
		} else if self.proposedEvent.type == .fade {
			if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
				self.proposedEvent.colors = self.proposedEvent.colors ?? []
				self.proposedEvent.colors?.append(.black)
				tableView.reloadData()
			} else {
				
				self.alerts.showActionSheet(withTitle: "What would you like to do with Fade Step \(indexPath.row + 1)", andDetail: nil, configs: [
					
					ActionConfig(title: "Edit Color", style: .default, callback: {
						self.colorController = DefaultColorPickerViewController()
						
						self.tmpIdx = indexPath.row
						if let hsb = self.proposedEvent.colors?[indexPath.row].hsba {
							self.colorController?.colorPalette.setSelectedHSBColor(HSBColor(hue: hsb.h, saturation: hsb.s, brightness: hsb.b), isInteractive: true)
						}
						
						self.colorController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissPicker))
						let navigationController = UINavigationController(rootViewController: self.colorController!)
						navigationController.modalPresentationStyle = .fullScreen
						self.present(navigationController, animated: true, completion: nil)
					}),
					ActionConfig(title: "Remove", style: .destructive, callback: {
						self.proposedEvent.colors?.remove(at: indexPath.row)
						self.table.reloadData()
					})
				])
				
				
			}
			
			
			
		} else if self.proposedEvent.type == .hold {
			self.colorController = DefaultColorPickerViewController()
			if let hsb = self.proposedEvent.color?.hsba {
				self.colorController?.colorPalette.setSelectedHSBColor(HSBColor(hue: hsb.h, saturation: hsb.s, brightness: hsb.b), isInteractive: true)
			}
			
			colorController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
			let navigationController = UINavigationController(rootViewController: colorController!)
			navigationController.modalPresentationStyle = .fullScreen
			present(navigationController, animated: true, completion: nil)
			
		} else {
			
		}
		
	}
	
	@objc func dismissPicker() {
		guard let ctrl = self.colorController else { return }
		ctrl.navigationController?.dismiss(animated: true, completion: nil)
		
		if self.proposedEvent.type == .strobe {
			
		} else if self.proposedEvent.type == .fade, let idx = self.tmpIdx {
			self.proposedEvent.colors?[idx] = ctrl.selectedColor
			self.table.reloadData()
			self.tmpIdx = nil
		} else if self.proposedEvent.type == .hold {
			self.proposedEvent.color = ctrl.selectedColor
			self.table.reloadData()
			
		} else {
			
		}
	}
	

}

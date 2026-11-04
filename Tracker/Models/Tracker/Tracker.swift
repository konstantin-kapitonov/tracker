//
//  Tracker.swift
//  Tracker
//
//  Created by Капитонов Константин on 01.11.2026.
//

import UIKit

// Значения совпадают с Calendar.Component.weekday: воскресенье — 1, суббота — 7.
enum Weekday: Int, CaseIterable, Hashable {
	case monday = 2
	case tuesday = 3
	case wednesday = 4
	case thursday = 5
	case friday = 6
	case saturday = 7
	case sunday = 1
}

struct Tracker: Hashable {
	let id: UUID
	let name: String
	let color: UIColor
	let emoji: String
	let schedule: Set<Weekday>
}

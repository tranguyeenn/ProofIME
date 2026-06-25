//
//  RelacementRule.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/25/26.
//

//
//  ReplacementRule.swift
//  ProofIME
//

import Foundation

struct ReplacementRule: Codable, Hashable {

	let trigger: String
	let output: String

	var mode: OutputMode = .unicode
	var requiresBoundary: Bool = true
	var priority: Int = 0
	var aliases: [String] = []

	var allTriggers: [String] {
		[trigger] + aliases
	}

	func matches(_ token: String) -> Bool {
		allTriggers.contains(token)
	}
}

extension Dictionary where Key == String, Value == String {

	func asReplacementRules(
		mode: OutputMode = .unicode
	) -> [ReplacementRule] {

		self.map { key, value in
			ReplacementRule(
				trigger: key,
				output: value,
				mode: mode,
				requiresBoundary: true,
				priority: 0,
				aliases: []
			)
		}
		.sorted {
			$0.trigger < $1.trigger
		}
	}
}

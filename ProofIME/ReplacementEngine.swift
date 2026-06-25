//
//  ReplacementEngine.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/25/26.
//

//
//  ReplacementEngine.swift
//  ProofIME
//

import Foundation

final class ReplacementEngine {

	private let rules: [ReplacementRule]

	init(rules: [ReplacementRule]) {
		self.rules = rules.sorted {
			$0.priority > $1.priority
		}
	}

	func replacement(for token: String) -> String? {
		print("Searching for:", token)

		let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines)

		let result = rules.first {
			$0.matches(normalized)
		}?.output

		print("Found:", result ?? "nil")

		return result
	}

	func rule(for token: String) -> ReplacementRule? {
		let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines)

		return rules.first {
			$0.matches(normalized)
		}
	}

	func hasReplacement(for token: String) -> Bool {
		replacement(for: token) != nil
	}

	func replacingRules(with newRules: [ReplacementRule]) -> ReplacementEngine {
		ReplacementEngine(rules: newRules)
	}
}

//
//  SymbolEngine.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

struct SymbolEngine {
	private let mappings: [String: String] = [
		"fa": "∀",
		"ex": "∃",
		"inn": "∈",
		"nin": "∉",
		"RR": "ℝ",
		"ZZ": "ℤ",
		"QQ": "ℚ",
		"NN": "ℕ",
		"=>": "⇒",
		"<=>": "⇔",
		"there4": "∴"
	]

	func transform(_ text: String) -> String {
		var result = text

		for shortcut in mappings.keys.sorted(by: { $0.count > $1.count }) {
			if let symbol = mappings[shortcut] {
				result = result.replacingOccurrences(of: shortcut, with: symbol)
			}
		}

		return result
	}
}

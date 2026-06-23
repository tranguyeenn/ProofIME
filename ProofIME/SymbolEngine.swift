//
//  SymbolEngine.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

struct SymbolEngine {

	private let unicodeMappings: [String: String]
	private let latexMappings: [String: String]

	init(
		unicodeMappings: [String: String] = SymbolLoader.loadMappings(),
		latexMappings: [String: String] = SymbolLoader.loadLatexMappings()
	) {
		self.unicodeMappings = unicodeMappings
		self.latexMappings = latexMappings
	}

	func transform(
		_ text: String,
		mode: OutputMode
	) -> String {

		let mappings =
			mode == .unicode
			? unicodeMappings
			: latexMappings

		var result = text

		for shortcut in mappings.keys.sorted(
			by: { $0.count > $1.count }
		) {

			if let symbol = mappings[shortcut] {

				result = result.replacingOccurrences(
					of: shortcut,
					with: symbol
				)
			}
		}

		return result
	}
}

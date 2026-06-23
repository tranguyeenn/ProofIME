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

	func transform(_ text: String, mode: OutputMode) -> String {
		let mappings = mode == .unicode ? unicodeMappings : latexMappings

		let tokens = text.split(
			separator: " ",
			omittingEmptySubsequences: false
		)

		return tokens
			.map { token in
				let word = String(token)
				return mappings[word] ?? word
			}
			.joined(separator: " ")
	}
}

//
//  SymbolLoader.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

final class SymbolLoader {

	static func loadMappings() -> [String: String] {

		guard let url = Bundle.main.url(
			forResource: "symbols",
			withExtension: "json"
		) else {
			print("symbols.json not found")
			return [:]
		}

		do {
			let data = try Data(contentsOf: url)

			let mappings = try JSONDecoder()
				.decode([String: String].self, from: data)

			print("Loaded mappings:", mappings.count)

			return mappings

		} catch {
			print("Failed to load mappings:", error)
			return [:]
		}
	}
	
	static func loadLatexMappings() -> [String: String] {

		[
			"fa": "\\forall",
			"ex": "\\exists",

			"inn": "\\in",
			"nin": "\\notin",

			"RR": "\\mathbb{R}",
			"ZZ": "\\mathbb{Z}",
			"QQ": "\\mathbb{Q}",
			"NN": "\\mathbb{N}",
			"CC": "\\mathbb{C}",

			"=>": "\\Rightarrow",
			"<=>": "\\Leftrightarrow",

			"andd": "\\land",
			"orr": "\\lor",
			"nott": "\\neg",

			"sub": "\\subseteq",
			"psub": "\\subset",

			"empty": "\\emptyset",

			"there4": "\\therefore",
			"becuz": "\\because",

			"!=": "\\neq",
			">=": "\\geq",
			"<=": "\\leq",

			"equiv": "\\equiv",
			"approx": "\\approx",

			"eps": "\\epsilon",
			"del": "\\delta",
			"lam": "\\lambda",
			"alp": "\\alpha",
			"bet": "\\beta"
		]
	}

	static func loadSymbolList() -> [SymbolMapping] {
		let mappings = loadMappings()

		return mappings
			.map {
				SymbolMapping(
					shortcut: $0.key,
					symbol: $0.value
				)
			}
			.sorted {
				$0.shortcut < $1.shortcut
			}
	}
}

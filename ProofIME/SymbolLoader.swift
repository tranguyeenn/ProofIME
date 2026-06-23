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

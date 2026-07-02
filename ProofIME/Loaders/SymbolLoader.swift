import Foundation

final class SymbolLoader {

	// MARK: - Legacy mappings

	static func loadMappings() -> [String: String] {
		AppConfig.ensureConfigDirectoryExists()

		if FileManager.default.fileExists(atPath: AppConfig.userSymbolsURL.path) {
			return loadMappings(from: AppConfig.userSymbolsURL)
		}

		guard let url = Bundle.main.url(
			forResource: "symbols",
			withExtension: "json"
		) else {
			print("symbols.json not found")
			return [:]
		}

		return loadMappings(from: url)
	}

	private static func loadMappings(from url: URL) -> [String: String] {
		do {
			let data = try Data(contentsOf: url)

			// First try old format:
			// { "fa": "∀", "ex": "∃" }
			if let mappings = try? JSONDecoder().decode([String: String].self, from: data) {
				print("Loaded legacy mappings:", mappings.count)
				return mappings
			}

			// Then try new rule format:
			// [ { "trigger": "fa", "output": "∀", ... } ]
			let rules = try JSONDecoder().decode([ReplacementRule].self, from: data)

			let mappings = Dictionary(
				uniqueKeysWithValues: rules.map { rule in
					(rule.trigger, rule.output)
				}
			)

			print("Loaded rule mappings:", mappings.count)
			return mappings

		} catch {
			print("Failed to load mappings:", error)
			return [:]
		}
	}

	// MARK: - Rule mappings

	static func loadRules() -> [ReplacementRule] {
		AppConfig.ensureConfigDirectoryExists()

		if FileManager.default.fileExists(atPath: AppConfig.userSymbolsURL.path) {
			return loadRules(from: AppConfig.userSymbolsURL)
		}

		guard let url = Bundle.main.url(
			forResource: "symbols",
			withExtension: "json"
		) else {
			print("symbols.json not found")
			return []
		}

		return loadRules(from: url)
	}

	private static func loadRules(from url: URL) -> [ReplacementRule] {
		do {
			let data = try Data(contentsOf: url)
			let decoder = JSONDecoder()

			// New format
			if let rules = try? decoder.decode([ReplacementRule].self, from: data) {
				print("Loaded rules:", rules.count)
				return rules.sorted { $0.priority > $1.priority }
			}

			// Old format fallback
			let mappings = try decoder.decode([String: String].self, from: data)
			let rules = mappings.asReplacementRules()

			print("Loaded legacy mappings as rules:", rules.count)
			return rules.sorted { $0.priority > $1.priority }

		} catch {
			print("Failed to load rules:", error)
			return []
		}
	}

	// MARK: - LaTeX mappings

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

	// MARK: - UI list

	static func loadSymbolList() -> [SymbolMapping] {
		let mappings = loadMappings()

		return mappings
			.map { SymbolMapping(shortcut: $0.key, symbol: $0.value) }
			.sorted { $0.shortcut < $1.shortcut }
	}
}

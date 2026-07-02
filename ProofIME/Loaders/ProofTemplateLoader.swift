import Foundation

enum ProofTemplateLoader {
	static func loadTemplates() -> [ProofTemplate] {
		guard let url = Bundle.main.url(
			forResource: "proof_templates",
			withExtension: "json"
		) else {
			print("Could not find proof_templates.json")
			return []
		}

		do {
			let data = try Data(contentsOf: url)
			return try JSONDecoder().decode([ProofTemplate].self, from: data)
		} catch {
			print("Failed to load proof templates: \(error)")
			return []
		}
	}
}

import Foundation

final class ProofTemplateLoader {

	static func loadTemplates() -> [String: String] {
		AppConfig.ensureConfigDirectoryExists()

		if FileManager.default.fileExists(atPath: AppConfig.userTemplatesURL.path) {
			return loadTemplates(from: AppConfig.userTemplatesURL)
		}

		guard let url = Bundle.main.url(
			forResource: "proof_templates",
			withExtension: "json"
		) else {
			print("proof_templates.json not found")
			return [:]
		}

		return loadTemplates(from: url)
	}

	private static func loadTemplates(from url: URL) -> [String: String] {
		do {
			let data = try Data(contentsOf: url)

			let templates = try JSONDecoder()
				.decode([String: String].self, from: data)

			print("Loaded templates:", templates.count)
			return templates
		} catch {
			print("Failed to load templates:", error)
			return [:]
		}
	}

	static func loadTemplateList() -> [ProofTemplate] {
		let templates = loadTemplates()

		return templates
			.map { ProofTemplate(name: $0.key, body: $0.value) }
			.sorted { $0.name < $1.name }
	}
}

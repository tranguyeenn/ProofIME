import SwiftUI
import UniformTypeIdentifiers

enum ReferencePanel: String, CaseIterable, Identifiable {
	case templates = "Templates"
	case symbols = "Symbols"

	var id: String { rawValue }
}

struct ContentView: View {

	@State private var input = ""
	@State private var mode: OutputMode = .unicode
	@State private var referencePanel: ReferencePanel = .templates
	@State private var customMappings: [String: String]? = nil

	private let templateEngine = TemplateEngine()

	private var engine: SymbolEngine {
		if let customMappings {
			return SymbolEngine(unicodeMappings: customMappings)
		}
		return SymbolEngine()
	}

	private var symbols: [SymbolMapping] {
		let mappings = customMappings ?? SymbolLoader.loadMappings()

		return mappings
			.map { SymbolMapping(shortcut: $0.key, symbol: $0.value) }
			.sorted { $0.shortcut < $1.shortcut }
	}

	private var templates: [ProofTemplate] {
		ProofTemplateLoader.loadTemplateList()
	}

	private var output: String {
		let expandedTemplate = templateEngine.expand(input)

		if expandedTemplate != input {
			return expandedTemplate
		}

		return engine.transform(input, mode: mode)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {

			Text("ProofIME")
				.font(.largeTitle)

			Picker("Mode", selection: $mode) {
				ForEach(OutputMode.allCases) { mode in
					Text(mode.rawValue).tag(mode)
				}
			}
			.pickerStyle(.segmented)

			HStack {
				Button("Import JSON") {
					importMappings()
				}

				Button("Reset") {
					customMappings = nil
				}
			}

			TextField(
				"Type: fa x inn RR or /template contradiction",
				text: $input
			)
			.textFieldStyle(.roundedBorder)

			Divider()

			Text("Output")
				.font(.headline)

			ScrollView {
				Text(output)
					.font(.title3)
					.frame(maxWidth: .infinity, alignment: .leading)
					.textSelection(.enabled)
			}
			.frame(height: 140)

			Divider()

			Picker("Reference", selection: $referencePanel) {
				ForEach(ReferencePanel.allCases) { panel in
					Text(panel.rawValue).tag(panel)
				}
			}
			.pickerStyle(.segmented)

			if referencePanel == .templates {
				Text("Proof Templates")
					.font(.headline)

				List(templates) { template in
					Button("/template \(template.name)") {
						input = "/template \(template.name)"
					}
				}
				.frame(height: 260)
			} else {
				Text("Available Symbols")
					.font(.headline)

				List(symbols) { item in
					HStack {
						Text(item.shortcut)
							.frame(width: 120, alignment: .leading)

						Text("→")

						Text(item.symbol)
							.font(.title3)
					}
				}
				.frame(height: 260)
			}

			Spacer()
		}
		.padding()
		.frame(width: 700, height: 650)
	}

	private func importMappings() {
		let panel = NSOpenPanel()
		panel.allowedContentTypes = [.json]
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false

		if panel.runModal() == .OK,
		   let url = panel.url {
			do {
				let data = try Data(contentsOf: url)

				let mappings = try JSONDecoder()
					.decode([String: String].self, from: data)

				customMappings = mappings
			} catch {
				print("Failed to import mappings:", error)
			}
		}
	}
}

#Preview {
	ContentView()
}

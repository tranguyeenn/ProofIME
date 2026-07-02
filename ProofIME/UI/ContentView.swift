import SwiftUI
import UniformTypeIdentifiers
import AppKit

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
	@State private var configReloadID = UUID()
	@State private var insertionRequest: String? = nil

	private var engine: SymbolEngine {
		if let customMappings {
			return SymbolEngine(unicodeMappings: customMappings)
		}

		return SymbolEngine()
	}

	private var replacementEngine: ReplacementEngine {
		let rules: [ReplacementRule]

		if let customMappings {
			rules = customMappings.asReplacementRules(mode: .unicode)
		} else {
			rules = SymbolLoader.loadRules()
		}

		return ReplacementEngine(rules: rules)
	}

	private var symbols: [SymbolMapping] {
		let mappings = customMappings ?? SymbolLoader.loadMappings()

		return mappings
			.map { SymbolMapping(shortcut: $0.key, symbol: $0.value) }
			.sorted { $0.shortcut < $1.shortcut }
	}

	private var templates: [ProofTemplate] {
		ProofTemplateLoader.loadTemplates()
	}

	private var output: String {
		if let directReplacement = replacementEngine.replacement(for: input) {
			return directReplacement
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
				Menu("Config") {
					Button("Import JSON") {
						importMappings()
					}

					Button("Reload Config") {
						reloadConfig()
					}

					Divider()

					Button("Open Config Folder") {
						AppConfig.openConfigDirectory()
					}

					Divider()

					Button("Delete Custom Symbols") {
						AppConfig.deleteUserSymbols()
						reloadConfig()
					}

					Button("Delete Custom Templates") {
						AppConfig.deleteUserTemplates()
						reloadConfig()
					}
				}
			}

			Text("Editor")
				.font(.headline)

			LiveReplacementTextView(
				text: $input,
				insertionRequest: $insertionRequest,
				replacementEngine: replacementEngine
			)
			.frame(height: 100)

			Divider()

			HStack {
				Text("Output")
					.font(.headline)

				Spacer()

				Button("Copy Output") {
					copyOutput()
				}

				Button("Save .txt") {
					saveOutput(fileExtension: "txt")
				}

				Button("Save .tex") {
					saveOutput(fileExtension: "tex")
				}
			}

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
					Button("\(template.trigger) → \(template.title)") {
						insertionRequest = template.body
					}
				}
				.frame(height: 260)
				.id(configReloadID)
			} else {
				Text("Available Symbols")
					.font(.headline)

				List(symbols) { item in
					Button {
						insertionRequest = item.symbol
					} label: {
						HStack {
							Text(item.shortcut)
								.frame(width: 120, alignment: .leading)

							Text("→")

							Text(item.symbol)
								.font(.title3)
						}
					}
				}
				.frame(height: 260)
				.id(configReloadID)
			}

			Spacer()
		}
		.padding()
		.frame(width: 760, height: 700)
	}

	private func reloadConfig() {
		customMappings = nil
		configReloadID = UUID()
	}

	private func copyOutput() {
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(output, forType: .string)
	}

	private func saveOutput(fileExtension: String) {
		let panel = NSSavePanel()
		panel.allowedContentTypes = fileExtension == "tex" ? [.tex] : [.plainText]
		panel.nameFieldStringValue = "proofime-output.\(fileExtension)"

		if panel.runModal() == .OK,
		   let url = panel.url {
			do {
				try output.write(
					to: url,
					atomically: true,
					encoding: .utf8
				)
			} catch {
				print("Failed to save output:", error)
			}
		}
	}

	private func importMappings() {
		let panel = NSOpenPanel()
		panel.allowedContentTypes = [.json]
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false

		if panel.runModal() == .OK,
		   let sourceURL = panel.url {

			do {
				AppConfig.ensureConfigDirectoryExists()

				let destinationURL = AppConfig.userSymbolsURL

				if FileManager.default.fileExists(atPath: destinationURL.path) {
					try FileManager.default.removeItem(at: destinationURL)
				}

				try FileManager.default.copyItem(
					at: sourceURL,
					to: destinationURL
				)

				print("Imported JSON to:", destinationURL.path)

				reloadConfig()

			} catch {
				print("Failed to import mappings:", error)
			}
		}
	}
}

#Preview {
	ContentView()
}

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

	private let templateEngine = TemplateEngine()

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
		ProofTemplateLoader.loadTemplateList()
	}

	private var output: String {
		let expandedTemplate = templateEngine.expand(input)

		if expandedTemplate != input {
			return expandedTemplate
		}

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

			TextField(
				"Type: fa x inn RR or /template contradiction",
				text: $input
			)
			.textFieldStyle(.roundedBorder)

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
					Button("/template \(template.name)") {
						input = "/template \(template.name)"
					}
				}
				.frame(height: 260)
				.id(configReloadID)
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
				.id(configReloadID)
			}

			Spacer()
		}
		.padding()
		.frame(width: 760, height: 700)
	}
	
	private func testReplacementEngine() {
		let engine = ReplacementEngine(
			rules: SymbolLoader.loadRules()
		)

		print("")
		print("========== ReplacementEngine Test ==========")

		print("fa ->", engine.replacement(for: "fa") ?? "nil")
		print("RR ->", engine.replacement(for: "RR") ?? "nil")
		print("feature ->", engine.replacement(for: "feature") ?? "nil")

		print("Has replacement for 'fa':",
			  engine.hasReplacement(for: "fa"))

		print("Has replacement for 'feature':",
			  engine.hasReplacement(for: "feature"))

		if let rule = engine.rule(for: "fa") {
			print("Matched rule:")
			print("Trigger:", rule.trigger)
			print("Output:", rule.output)
			print("Aliases:", rule.aliases)
			print("Priority:", rule.priority)
		} else {
			print("No rule found for 'fa'")
		}

		print("============================================")
		print("")
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

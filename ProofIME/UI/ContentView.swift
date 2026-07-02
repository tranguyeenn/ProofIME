import SwiftUI
import UniformTypeIdentifiers
import AppKit

enum ReferencePanel: String, CaseIterable, Identifiable {
	case templates = "Templates"
	case symbols = "Symbols"

	var id: String { rawValue }
}

private struct CandidateOption: Identifiable, Hashable {
	let id = UUID()
	let token: String
	let replacement: String
	let label: String
}

struct ContentView: View {

	@State private var input = ""
	@State private var mode: OutputMode = .unicode
	@State private var referencePanel: ReferencePanel = .templates

	@State private var customMappings: [String: String]? = nil
	@State private var configReloadID = UUID()
	@State private var insertionRequest: String? = nil
	@State private var replacementRequest: TokenCandidate? = nil

	@State private var templateSearch = ""
	@State private var symbolSearch = ""
	@State private var cursorPosition = 0

	@State private var selectedCandidateIndex = 0

	@AppStorage("favoriteTemplateIDs")
	private var favoriteTemplateIDsRaw = ""

	private var favoriteTemplateIDs: Set<String> {
		get {
			Set(
				favoriteTemplateIDsRaw
					.split(separator: ",")
					.map(String.init)
			)
		}
		nonmutating set {
			favoriteTemplateIDsRaw = newValue
				.sorted()
				.joined(separator: ",")
		}
	}

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

	private var filteredTemplates: [ProofTemplate] {
		let query = templateSearch.trimmingCharacters(in: .whitespacesAndNewlines)

		let source: [ProofTemplate]

		if query.isEmpty {
			source = templates
		} else {
			source = templates.filter { template in
				template.trigger.localizedCaseInsensitiveContains(query)
				|| template.title.localizedCaseInsensitiveContains(query)
				|| template.body.localizedCaseInsensitiveContains(query)
			}
		}

		return source.sorted { lhs, rhs in
			let lhsFavorite = favoriteTemplateIDs.contains(lhs.id)
			let rhsFavorite = favoriteTemplateIDs.contains(rhs.id)

			if lhsFavorite != rhsFavorite {
				return lhsFavorite && !rhsFavorite
			}

			return lhs.trigger < rhs.trigger
		}
	}

	private var favoriteTemplates: [ProofTemplate] {
		templates
			.filter { favoriteTemplateIDs.contains($0.id) }
			.sorted { $0.trigger < $1.trigger }
	}

	private var filteredSymbols: [SymbolMapping] {
		let query = symbolSearch.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !query.isEmpty else {
			return symbols
		}

		return symbols.filter { symbol in
			symbol.shortcut.localizedCaseInsensitiveContains(query)
			|| symbol.symbol.localizedCaseInsensitiveContains(query)
		}
	}

	private var currentCandidate: TokenCandidate? {
		let processor = TokenProcessor(
			replacementEngine: replacementEngine
		)

		return processor.candidate(
			in: input,
			cursorPosition: cursorPosition
		)
	}

	private var candidateOptions: [CandidateOption] {
		guard let candidate = currentCandidate else {
			return []
		}

		var options: [CandidateOption] = [
			CandidateOption(
				token: candidate.token,
				replacement: candidate.replacement,
				label: "default"
			)
		]

		if candidate.token == "fa" {
			options.append(contentsOf: [
				CandidateOption(token: candidate.token, replacement: "∧", label: "and"),
				CandidateOption(token: candidate.token, replacement: "⇒", label: "implies")
			])
		}

		if candidate.token == "and" {
			options.append(contentsOf: [
				CandidateOption(token: candidate.token, replacement: "∩", label: "intersection"),
				CandidateOption(token: candidate.token, replacement: "∧", label: "logical and")
			])
		}

		var seen = Set<String>()

		return options.filter { option in
			if seen.contains(option.replacement) {
				return false
			}

			seen.insert(option.replacement)
			return true
		}
	}

	private var selectedCandidate: CandidateOption? {
		guard candidateOptions.indices.contains(selectedCandidateIndex) else {
			return candidateOptions.first
		}

		return candidateOptions[selectedCandidateIndex]
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

				Spacer()

				Button("Clear Editor") {
					input = ""
					cursorPosition = 0
					selectedCandidateIndex = 0
				}
			}

			Text("Editor")
				.font(.headline)

			LiveReplacementTextView(
				text: $input,
				insertionRequest: $insertionRequest,
				replacementRequest: $replacementRequest,
				cursorPosition: $cursorPosition,
				replacementEngine: replacementEngine,
				onArrowUp: {
					handleMove(.up)
				},
				onArrowDown: {
					handleMove(.down)
				},
				onEnter: {
					commitSelectedCandidate()
				},
				onEscape: {
					selectedCandidateIndex = 0
				}
			)
			.frame(height: 100)
			.frame(height: 100)

			candidatePreview

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
				templateReferencePanel
			} else {
				symbolReferencePanel
			}

			Spacer()
		}
		.padding()
		.frame(width: 760, height: 790)
		.onMoveCommand { direction in
			handleMove(direction)
		}
		.onExitCommand {
			selectedCandidateIndex = 0
		}
		.onChange(of: currentCandidate?.token) {
			selectedCandidateIndex = 0
		}
	}

	private var candidatePreview: some View {
		Group {
			if !candidateOptions.isEmpty {
				VStack(alignment: .leading, spacing: 6) {
					HStack {
						Text("Current token:")
							.foregroundStyle(.secondary)

						Text(candidateOptions[0].token)
							.font(.system(.body, design: .monospaced))

						Spacer()

						Button("Insert Selected") {
							commitSelectedCandidate()
						}
						.keyboardShortcut(.return, modifiers: [])
					}

					VStack(alignment: .leading, spacing: 4) {
						ForEach(Array(candidateOptions.enumerated()), id: \.element.id) { index, option in
							Button {
								selectedCandidateIndex = index
								commitSelectedCandidate()
							} label: {
								HStack(spacing: 10) {
									Text(index == selectedCandidateIndex ? "▶" : " ")
										.font(.system(.body, design: .monospaced))
										.frame(width: 18)

									Text(option.replacement)
										.font(.title3)
										.frame(width: 32, alignment: .leading)

									Text(option.label)
										.foregroundStyle(.secondary)

									Spacer()
								}
								.padding(.vertical, 3)
								.padding(.horizontal, 8)
								.background(
									index == selectedCandidateIndex
									? Color.accentColor.opacity(0.15)
									: Color.clear
								)
								.clipShape(RoundedRectangle(cornerRadius: 6))
							}
							.buttonStyle(.plain)
						}
					}
					.padding(8)
					.background(.thinMaterial)
					.clipShape(RoundedRectangle(cornerRadius: 10))
				}
				.padding(.vertical, 4)
			}
		}
	}

	private var templateReferencePanel: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Proof Templates")
				.font(.headline)

			TextField("Search templates by trigger, title, or body...", text: $templateSearch)
				.textFieldStyle(.roundedBorder)

			if !favoriteTemplates.isEmpty && templateSearch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				Text("Favorites")
					.font(.subheadline)
					.foregroundStyle(.secondary)

				ScrollView(.horizontal) {
					HStack {
						ForEach(favoriteTemplates) { template in
							Button("★ \(template.trigger)") {
								insertionRequest = template.body
							}
						}
					}
				}
			}

			List(filteredTemplates) { template in
				templateRow(template)
			}
			.frame(height: 260)
			.id(configReloadID)
		}
	}

	private var symbolReferencePanel: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Available Symbols")
				.font(.headline)

			TextField("Search symbols by shortcut or symbol...", text: $symbolSearch)
				.textFieldStyle(.roundedBorder)

			List(filteredSymbols) { item in
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
	}

	private func handleMove(_ direction: MoveCommandDirection) {
		guard !candidateOptions.isEmpty else {
			return
		}

		switch direction {
		case .down:
			selectedCandidateIndex = (selectedCandidateIndex + 1) % candidateOptions.count

		case .up:
			selectedCandidateIndex = (selectedCandidateIndex - 1 + candidateOptions.count) % candidateOptions.count

		default:
			break
		}
	}

	private func commitSelectedCandidate() {
		guard let option = selectedCandidate else {
			return
		}

		replaceToken(
			option.token,
			with: option.replacement
		)

		selectedCandidateIndex = 0
	}

	private func replaceToken(_ token: String, with replacement: String) {
		guard !token.isEmpty else {
			return
		}

		let safeCursor = min(
			max(cursorPosition, 0),
			input.count
		)

		guard safeCursor >= token.count else {
			return
		}

		let endIndex = input.index(
			input.startIndex,
			offsetBy: safeCursor
		)

		let startIndex = input.index(
			endIndex,
			offsetBy: -token.count
		)

		input.replaceSubrange(
			startIndex..<endIndex,
			with: replacement
		)

		cursorPosition = safeCursor - token.count + replacement.count
	}

	private func templateRow(_ template: ProofTemplate) -> some View {
		HStack(alignment: .top) {
			Button {
				toggleFavorite(template)
			} label: {
				Text(favoriteTemplateIDs.contains(template.id) ? "★" : "☆")
					.font(.title3)
			}
			.buttonStyle(.plain)

			Button {
				insertionRequest = template.body
			} label: {
				VStack(alignment: .leading, spacing: 4) {
					Text("\(template.trigger) → \(template.title)")
						.font(.headline)

					Text(template.body)
						.font(.caption)
						.foregroundStyle(.secondary)
						.lineLimit(2)
				}
				.padding(.vertical, 4)
			}
			.buttonStyle(.plain)
		}
	}

	private func toggleFavorite(_ template: ProofTemplate) {
		var ids = favoriteTemplateIDs

		if ids.contains(template.id) {
			ids.remove(template.id)
		} else {
			ids.insert(template.id)
		}

		favoriteTemplateIDs = ids
	}

	private func reloadConfig() {
		customMappings = nil
		templateSearch = ""
		symbolSearch = ""
		configReloadID = UUID()
		selectedCandidateIndex = 0
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

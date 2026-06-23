//
//  ContentView.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {

	@State private var input = ""
	@State private var mode: OutputMode = .unicode
	@State private var customMappings: [String: String]? = nil

	private let defaultSymbols = SymbolLoader.loadSymbolList()

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

			TextField("Type: fa x inn RR => ex y inn ZZ", text: $input)
				.textFieldStyle(.roundedBorder)

			Divider()

			Text("Output")
				.font(.headline)

			Text(engine.transform(input, mode: mode))
				.font(.title2)

			Divider()

			Text("Available Symbols")
				.font(.headline)

			List(symbols) { item in
				HStack {
					Text(item.shortcut)
						.frame(width: 100, alignment: .leading)

					Text("→")

					Text(item.symbol)
						.font(.title3)
				}
			}
			.frame(height: 180)

			Spacer()
		}
		.padding()
		.frame(width: 650, height: 600)
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

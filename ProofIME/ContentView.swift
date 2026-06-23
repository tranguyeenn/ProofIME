//
//  ContentView.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import SwiftUI

struct ContentView: View {

	@State private var input = ""

	private let engine = SymbolEngine()
	private let symbols = SymbolLoader.loadSymbolList()

	var body: some View {

		VStack(alignment: .leading, spacing: 16) {

			Text("ProofIME")
				.font(.largeTitle)

			TextField(
				"Type: fa x inn RR => ex y inn ZZ",
				text: $input
			)
			.textFieldStyle(.roundedBorder)

			Divider()

			Text("Output")
				.font(.headline)

			Text(engine.transform(input))
				.font(.title2)

			Divider()

			Text("Available Symbols")
				.font(.headline)

			List(symbols) { item in

				HStack {

					Text(item.shortcut)
						.frame(
							width: 100,
							alignment: .leading
						)

					Text("→")

					Text(item.symbol)
						.font(.title3)
				}
			}
			.frame(height: 180)

			Spacer()
		}
		.padding()
		.frame(width: 600, height: 500)
	}
}

#Preview {
	ContentView()
}

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

			Spacer()
		}
		.padding()
		.frame(width: 600, height: 300)
	}
}

#Preview {
	ContentView()
}

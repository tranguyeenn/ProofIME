//
//  CandidateListView.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/2/26.
//

import SwiftUI

struct CandidateListView: View {

	@ObservedObject var manager: CandidateManager

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {

			ForEach(
				Array(manager.candidates.enumerated()),
				id: \.element.id
			) { index, candidate in

				HStack {

					Text(
						index == manager.selectedIndex
						? "▶"
						: " "
					)

					Text(candidate.text)

					if let label = candidate.label {
						Text(label)
							.foregroundStyle(.secondary)
					}
				}
			}
		}
		.padding()
		.background(.thinMaterial)
		.clipShape(
			RoundedRectangle(cornerRadius: 10)
		)
	}
}

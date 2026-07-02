//
//  CandidatePopupView.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/2/26.
//

import SwiftUI

struct CandidatePopupView: View {

	let candidates: [CandidateOption]
	let selectedIndex: Int

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {

			ForEach(
				Array(candidates.enumerated()),
				id: \.element.id
			) { index, option in

				HStack {
					Text(
						index == selectedIndex
						? "▶"
						: " "
					)

					Text(option.replacement)

					Text(option.label)
						.foregroundStyle(.secondary)
				}
				.padding(.horizontal, 8)
				.padding(.vertical, 4)
				.background(
					index == selectedIndex
					? Color.accentColor.opacity(0.15)
					: Color.clear
				)
			}
		}
		.padding(8)
		.background(.regularMaterial)
		.clipShape(
			RoundedRectangle(cornerRadius: 10)
		)
		.shadow(radius: 6)
	}
}

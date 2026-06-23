//
//  TemplateEngine.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

struct TemplateEngine {
	private let templates: [String: String]

	init(
		templates: [String: String] = ProofTemplateLoader.loadTemplates()
	) {
		self.templates = templates
	}

	func expand(_ text: String) -> String {
		guard text.hasPrefix("/template ") else {
			return text
		}

		let key = text
			.replacingOccurrences(of: "/template ", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)

		return templates[key] ?? text
	}
}

//
//  TemplateEngine.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

final class TemplateEngine {
	private let templates: [ProofTemplate]

	init(templates: [ProofTemplate] = ProofTemplateLoader.loadTemplates()) {
		self.templates = templates
	}

	func template(for trigger: String) -> ProofTemplate? {
		templates.first { $0.trigger == trigger }
	}

	func expansion(for trigger: String) -> String? {
		template(for: trigger)?.body
	}
}

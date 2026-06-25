//
//  Tokenizer.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/25/26.
//

import Foundation

struct Tokenizer {

	static let boundaryCharacters = CharacterSet.whitespacesAndNewlines
		.union(.punctuationCharacters)

	static func tokens(from text: String) -> [String] {
		text
			.components(separatedBy: boundaryCharacters)
			.filter { !$0.isEmpty }
	}

	static func currentToken(in text: String) -> String {
		guard let last = tokens(from: text).last else {
			return ""
		}

		return last
	}

	static func endsWithBoundary(_ text: String) -> Bool {
		guard let lastScalar = text.unicodeScalars.last else {
			return false
		}

		return boundaryCharacters.contains(lastScalar)
	}

	static func tokenBeforeBoundary(in text: String) -> String {
		let trimmed = text.trimmingCharacters(in: boundaryCharacters)

		guard let last = tokens(from: trimmed).last else {
			return ""
		}

		return last
	}
}

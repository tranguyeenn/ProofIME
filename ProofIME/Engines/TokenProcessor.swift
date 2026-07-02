//
//  TokenProcessor.swift
//  ProofIME
//

import Foundation

struct TokenCandidate: Equatable {
	let token: String
	let replacement: String
}

struct TokenProcessor {

	let replacementEngine: ReplacementEngine

	func currentToken(
		in text: String,
		cursorPosition: Int
	) -> String? {
		guard !text.isEmpty else {
			return nil
		}

		let safeCursorPosition = max(
			0,
			min(cursorPosition, text.count)
		)

		guard safeCursorPosition > 0 else {
			return nil
		}

		let cursorIndex = text.index(
			text.startIndex,
			offsetBy: safeCursorPosition
		)

		let beforeCursor = String(text[..<cursorIndex])

		let separators = CharacterSet.whitespacesAndNewlines
			.union(.punctuationCharacters)

		let parts = beforeCursor.components(
			separatedBy: separators
		)

		guard let token = parts.last,
			  !token.isEmpty else {
			return nil
		}

		return token
	}

	func candidate(
		in text: String,
		cursorPosition: Int
	) -> TokenCandidate? {
		guard let token = currentToken(
			in: text,
			cursorPosition: cursorPosition
		) else {
			return nil
		}

		guard let replacement = replacementEngine.replacement(for: token) else {
			return nil
		}

		return TokenCandidate(
			token: token,
			replacement: replacement
		)
	}

	func hasReplacement(
		in text: String,
		cursorPosition: Int
	) -> Bool {
		candidate(
			in: text,
			cursorPosition: cursorPosition
		) != nil
	}

	func process(
		text: String,
		cursorPosition: Int,
		trigger: String
	) -> ReplacementResult {
		let controller = LiveReplacementController(
			replacementEngine: replacementEngine
		)

		return controller.processTrigger(
			text: text,
			cursorPosition: cursorPosition,
			trigger: trigger
		)
	}
}

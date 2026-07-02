//
//  TokenProcessor.swift
//  ProofIME
//

import Foundation

struct TokenCandidate: Equatable {
	let token: String
	let replacement: String
	let range: NSRange
}

struct TokenProcessor {

	let replacementEngine: ReplacementEngine

	func currentTokenRange(
		in text: String,
		cursorPosition: Int
	) -> NSRange? {
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

		let characters = Array(text)

		var start = safeCursorPosition

		while start > 0 {
			let previousCharacter = characters[start - 1]

			if isTokenBoundary(previousCharacter) {
				break
			}

			start -= 1
		}

		let length = safeCursorPosition - start

		guard length > 0 else {
			return nil
		}

		return NSRange(location: start, length: length)
	}

	func currentToken(
		in text: String,
		cursorPosition: Int
	) -> String? {
		guard let range = currentTokenRange(
			in: text,
			cursorPosition: cursorPosition
		) else {
			return nil
		}

		let characters = Array(text)
		let tokenCharacters = characters[range.location..<(range.location + range.length)]

		return String(tokenCharacters)
	}

	func candidate(
		in text: String,
		cursorPosition: Int
	) -> TokenCandidate? {
		guard let range = currentTokenRange(
			in: text,
			cursorPosition: cursorPosition
		) else {
			return nil
		}

		let characters = Array(text)
		let token = String(
			characters[range.location..<(range.location + range.length)]
		)

		guard let replacement = replacementEngine.replacement(for: token) else {
			return nil
		}

		return TokenCandidate(
			token: token,
			replacement: replacement,
			range: range
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

	private func isTokenBoundary(_ character: Character) -> Bool {
		character.unicodeScalars.allSatisfy { scalar in
			CharacterSet.whitespacesAndNewlines.contains(scalar)
			|| CharacterSet.punctuationCharacters.contains(scalar)
		}
	}
}

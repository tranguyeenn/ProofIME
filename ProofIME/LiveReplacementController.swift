//
//  LiveReplacementController.swift
//  ProofIME
//

import Foundation

enum ReplacementTrigger {
	case space
	case tab
	case enter

	var insertedText: String {
		switch self {
		case .space:
			return " "
		case .tab:
			return ""
		case .enter:
			return "\n"
		}
	}
}

struct LiveReplacementResult {
	let text: String
	let cursorOffset: Int
	let didReplace: Bool
}

struct LiveReplacementController {
	let engine: ReplacementEngine

	func handleTrigger(
		text: String,
		cursorOffset: Int,
		trigger: ReplacementTrigger
	) -> LiveReplacementResult {
		guard cursorOffset >= 0, cursorOffset <= text.count else {
			return LiveReplacementResult(
				text: text,
				cursorOffset: text.count,
				didReplace: false
			)
		}

		let cursorIndex = text.index(text.startIndex, offsetBy: cursorOffset)
		let beforeCursor = String(text[..<cursorIndex])
		let afterCursor = String(text[cursorIndex...])

		guard let tokenRange = currentTokenRange(in: beforeCursor) else {
			let newText = beforeCursor + trigger.insertedText + afterCursor

			return LiveReplacementResult(
				text: newText,
				cursorOffset: beforeCursor.count + trigger.insertedText.count,
				didReplace: false
			)
		}

		let token = String(beforeCursor[tokenRange])

		guard let replacement = engine.replacement(for: token) else {
			let newText = beforeCursor + trigger.insertedText + afterCursor

			return LiveReplacementResult(
				text: newText,
				cursorOffset: beforeCursor.count + trigger.insertedText.count,
				didReplace: false
			)
		}

		let replacedBeforeCursor = beforeCursor.replacingCharacters(
			in: tokenRange,
			with: replacement
		)

		let newText = replacedBeforeCursor + trigger.insertedText + afterCursor
		let newCursorOffset = replacedBeforeCursor.count + trigger.insertedText.count

		return LiveReplacementResult(
			text: newText,
			cursorOffset: newCursorOffset,
			didReplace: true
		)
	}

	private func currentTokenRange(in text: String) -> Range<String.Index>? {
		guard !text.isEmpty else { return nil }

		var start = text.endIndex

		while start > text.startIndex {
			let previous = text.index(before: start)
			let character = text[previous]

			if isBoundary(character) {
				break
			}

			start = previous
		}

		guard start < text.endIndex else { return nil }

		return start..<text.endIndex
	}

	private func isBoundary(_ character: Character) -> Bool {
		character.isWhitespace ||
		character == "," ||
		character == "." ||
		character == ";" ||
		character == ":" ||
		character == "(" ||
		character == ")" ||
		character == "[" ||
		character == "]" ||
		character == "{" ||
		character == "}"
	}
}

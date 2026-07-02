// Controllers/LiveReplacementController.swift
import Foundation

struct ReplacementResult {
	let text: String
	let cursorPosition: Int
	let didReplace: Bool
}

final class LiveReplacementController {

	private let replacementEngine: ReplacementEngine
	private let templateEngine: TemplateEngine

	init(
		replacementEngine: ReplacementEngine,
		templateEngine: TemplateEngine = TemplateEngine()
	) {
		self.replacementEngine = replacementEngine
		self.templateEngine = templateEngine
	}

	func processTrigger(
		text: String,
		cursorPosition: Int,
		trigger: String
	) -> ReplacementResult {

		guard cursorPosition <= text.count else {
			return ReplacementResult(
				text: text,
				cursorPosition: text.count,
				didReplace: false
			)
		}

		let prefix = String(text.prefix(cursorPosition))
		let suffix = String(text.dropFirst(cursorPosition))

		guard let tokenRange = findTokenRange(in: prefix) else {
			let newText = prefix + trigger + suffix
			return ReplacementResult(
				text: newText,
				cursorPosition: cursorPosition + trigger.count,
				didReplace: false
			)
		}

		let token = String(prefix[tokenRange])

		if let template = templateEngine.expansion(for: token) {
			let beforeToken = String(prefix[..<tokenRange.lowerBound])
			let newText = beforeToken + template + trigger + suffix
			let newCursorPosition = beforeToken.count + template.count + trigger.count

			return ReplacementResult(
				text: newText,
				cursorPosition: newCursorPosition,
				didReplace: true
			)
		}

		if let replacement = replacementEngine.replacement(for: token) {
			let beforeToken = String(prefix[..<tokenRange.lowerBound])
			let newText = beforeToken + replacement + trigger + suffix
			let newCursorPosition = beforeToken.count + replacement.count + trigger.count

			return ReplacementResult(
				text: newText,
				cursorPosition: newCursorPosition,
				didReplace: true
			)
		}

		let newText = prefix + trigger + suffix
		return ReplacementResult(
			text: newText,
			cursorPosition: cursorPosition + trigger.count,
			didReplace: false
		)
	}

	private func findTokenRange(in text: String) -> Range<String.Index>? {
		guard !text.isEmpty else { return nil }

		var startIndex = text.endIndex

		while startIndex > text.startIndex {
			let previousIndex = text.index(before: startIndex)
			let character = text[previousIndex]

			if character.isWhitespace {
				break
			}

			startIndex = previousIndex
		}

		guard startIndex < text.endIndex else { return nil }
		return startIndex..<text.endIndex
	}
}

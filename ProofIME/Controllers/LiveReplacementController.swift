// Controllers/LiveReplacementController.swift

import Foundation

struct ReplacementResult {
	let text: String
	let cursorPosition: Int
	let didReplace: Bool
}

final class LiveReplacementController {

	private let replacementEngine: ReplacementEngine

	init(replacementEngine: ReplacementEngine) {
		self.replacementEngine = replacementEngine
	}

	func processTrigger(
		text: String,
		cursorPosition: Int,
		trigger: String = " "
	) -> ReplacementResult {

		guard cursorPosition <= text.count else {
			return .init(
				text: text,
				cursorPosition: cursorPosition,
				didReplace: false
			)
		}

		let prefix = String(text.prefix(cursorPosition))

		let parts = prefix.split(separator: " ", omittingEmptySubsequences: false)

		guard let last = parts.last else {
			return .init(
				text: text + trigger,
				cursorPosition: cursorPosition + trigger.count,
				didReplace: false
			)
		}

		let token = String(last)

		guard let replacement = replacementEngine.replacement(for: token) else {

			let newText = text + trigger

			return .init(
				text: newText,
				cursorPosition: cursorPosition + trigger.count,
				didReplace: false
			)
		}

		let startIndex = text.index(
			text.endIndex,
			offsetBy: -token.count
		)

		let replaced =
			String(text[..<startIndex]) +
			replacement +
			trigger

		return .init(
			text: replaced,
			cursorPosition: replaced.count,
			didReplace: true
		)
	}
}

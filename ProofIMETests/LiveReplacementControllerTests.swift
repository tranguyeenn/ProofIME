//
//  LiveReplacementControllerTests.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/1/26.
//

import Testing
@testable import ProofIME

struct LiveReplacementControllerTests {

	@Test
	func replacesForAllOnSpace() {
		let engine = ReplacementEngine(
			rules: [
				ReplacementRule(trigger: "fa", output: "∀")
			]
		)

		let controller = LiveReplacementController(
			replacementEngine: engine
		)

		let result = controller.processTrigger(
			text: "fa",
			cursorPosition: 2
		)

		#expect(result.text == "∀ ")
		#expect(result.didReplace)
	}
}

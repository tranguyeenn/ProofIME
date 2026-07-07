import InputMethodKit

@objc(InputController)
final class InputController: IMKInputController {

	private var buffer = ""

	override func inputText(
		_ string: String!,
		key keyCode: Int,
		modifiers flags: Int,
		client sender: Any!
	) -> Bool {

		guard let string else {
			return false
		}
		let sender = sender as AnyObject

		if string == " " {
			if buffer == "fa" {
				sender.insertText(
					"∀",
					replacementRange: NSRange(
						location: NSNotFound,
						length: 0
					)
				)

				buffer = ""
				return true
			}

			sender.insertText(
				buffer + " ",
				replacementRange: NSRange(
					location: NSNotFound,
					length: 0
				)
			)

			buffer = ""
			return true
		}

		buffer += string
		return true
	}
}

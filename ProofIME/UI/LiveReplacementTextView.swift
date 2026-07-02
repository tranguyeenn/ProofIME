//
//  LiveReplacementTextView.swift
//  ProofIME
//

import SwiftUI
import AppKit

struct LiveReplacementTextView: NSViewRepresentable {
	@Binding var text: String
	@Binding var insertionRequest: String?
	@Binding var cursorPosition: Int

	let replacementEngine: ReplacementEngine

	func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.borderType = .bezelBorder

		let textView = ProofTextView()

		textView.isEditable = true
		textView.isSelectable = true
		textView.font = .systemFont(ofSize: 16)

		textView.drawsBackground = true
		textView.backgroundColor = .windowBackgroundColor
		textView.textColor = .white
		textView.insertionPointColor = .white
		textView.typingAttributes = [
			.font: NSFont.systemFont(ofSize: 16),
			.foregroundColor: NSColor.white
		]

		textView.delegate = context.coordinator
		textView.replacementEngine = replacementEngine

		textView.onTextChange = { newText in
			text = newText
		}

		textView.onCursorChange = { newPosition in
			cursorPosition = newPosition
		}

		scrollView.documentView = textView

		return scrollView
	}

	func updateNSView(_ scrollView: NSScrollView, context: Context) {
		guard let textView = scrollView.documentView as? ProofTextView else {
			return
		}

		textView.replacementEngine = replacementEngine
		textView.forceEditorStyle()

		if textView.string != text {
			textView.string = text
			textView.forceEditorStyle()
		}

		if let insertionRequest {
			textView.insertTextAtCursor(insertionRequest)

			DispatchQueue.main.async {
				self.text = textView.string
				self.cursorPosition = textView.selectedRange().location
				self.insertionRequest = nil
				textView.forceEditorStyle()
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	final class Coordinator: NSObject, NSTextViewDelegate {
		let parent: LiveReplacementTextView

		init(parent: LiveReplacementTextView) {
			self.parent = parent
		}

		func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? ProofTextView else {
				return
			}

			textView.forceEditorStyle()
			parent.text = textView.string
			parent.cursorPosition = textView.selectedRange().location
		}

		func textViewDidChangeSelection(_ notification: Notification) {
			guard let textView = notification.object as? ProofTextView else {
				return
			}

			parent.cursorPosition = textView.selectedRange().location
		}
	}
}

final class ProofTextView: NSTextView {
	var replacementEngine: ReplacementEngine?
	var onTextChange: ((String) -> Void)?
	var onCursorChange: ((Int) -> Void)?

	func forceEditorStyle() {
		font = .systemFont(ofSize: 16)
		drawsBackground = true
		backgroundColor = .windowBackgroundColor
		textColor = .white
		insertionPointColor = .white

		typingAttributes = [
			.font: NSFont.systemFont(ofSize: 16),
			.foregroundColor: NSColor.white
		]

		textStorage?.addAttributes(
			[
				.font: NSFont.systemFont(ofSize: 16),
				.foregroundColor: NSColor.white
			],
			range: NSRange(location: 0, length: string.count)
		)
	}

	func insertTextAtCursor(_ insertedText: String) {
		let range = selectedRange()

		if let textStorage {
			textStorage.replaceCharacters(in: range, with: insertedText)

			let newCursorPosition = range.location + insertedText.count

			setSelectedRange(
				NSRange(
					location: newCursorPosition,
					length: 0
				)
			)

			forceEditorStyle()
			onTextChange?(string)
			onCursorChange?(newCursorPosition)
		}
	}

	override func keyDown(with event: NSEvent) {
		guard let characters = event.charactersIgnoringModifiers else {
			super.keyDown(with: event)
			forceEditorStyle()
			onTextChange?(string)
			onCursorChange?(selectedRange().location)
			return
		}

		let trigger: String?

		switch characters {
		case " ":
			trigger = " "

		case "\t":
			trigger = "\t"

		case "\r":
			trigger = "\n"

		default:
			trigger = nil
		}

		guard let trigger,
			  let replacementEngine else {
			super.keyDown(with: event)
			forceEditorStyle()
			onTextChange?(string)
			onCursorChange?(selectedRange().location)
			return
		}

		let cursorPosition = selectedRange().location

		let processor = TokenProcessor(
			replacementEngine: replacementEngine
		)

		let result = processor.process(
			text: string,
			cursorPosition: cursorPosition,
			trigger: trigger
		)

		if result.didReplace {
			string = result.text

			setSelectedRange(
				NSRange(
					location: result.cursorPosition,
					length: 0
				)
			)

			forceEditorStyle()
			onTextChange?(result.text)
			onCursorChange?(result.cursorPosition)
		} else {
			super.keyDown(with: event)
			forceEditorStyle()
			onTextChange?(string)
			onCursorChange?(selectedRange().location)
		}
	}
}

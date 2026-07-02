//
//  LiveReplacementTextView.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/1/26.
//

import SwiftUI
import AppKit

struct LiveReplacementTextView: NSViewRepresentable {
	@Binding var text: String

	let replacementEngine: ReplacementEngine

	func makeNSView(context: Context) -> NSScrollView {
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.borderType = .bezelBorder

		let textView = ProofTextView()
		textView.isEditable = true
		textView.isSelectable = true
		textView.font = .systemFont(ofSize: 16)
		textView.delegate = context.coordinator
		textView.replacementEngine = replacementEngine
		textView.onTextChange = { newText in
			text = newText
		}

		scrollView.documentView = textView

		return scrollView
	}

	func updateNSView(_ scrollView: NSScrollView, context: Context) {
		guard let textView = scrollView.documentView as? ProofTextView else {
			return
		}

		textView.replacementEngine = replacementEngine

		if textView.string != text {
			textView.string = text
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

			parent.text = textView.string
		}
	}
}

final class ProofTextView: NSTextView {
	var replacementEngine: ReplacementEngine?
	var onTextChange: ((String) -> Void)?

	override func keyDown(with event: NSEvent) {
		guard let characters = event.charactersIgnoringModifiers else {
			super.keyDown(with: event)
			return
		}

		let trigger: ReplacementTrigger?

		switch characters {
		case " ":
			trigger = .space
		case "\t":
			trigger = .tab
		case "\r":
			trigger = .enter
		default:
			trigger = nil
		}

		guard let trigger,
			  let replacementEngine else {
			super.keyDown(with: event)
			return
		}

		let cursorOffset = selectedRange().location
		let controller = LiveReplacementController(engine: replacementEngine)

		let result = controller.handleTrigger(
			text: string,
			cursorOffset: cursorOffset,
			trigger: trigger
		)

		if result.didReplace {
			string = result.text
			setSelectedRange(NSRange(location: result.cursorOffset, length: 0))
			onTextChange?(result.text)
		} else {
			super.keyDown(with: event)
			onTextChange?(string)
		}
	}
}

import Foundation
import Combine

final class CandidateManager: ObservableObject {

	@Published private(set) var candidates: [Candidate] = []
	@Published private(set) var selectedIndex = 0

	var isActive: Bool {
		!candidates.isEmpty
	}

	var selectedCandidate: Candidate? {
		guard candidates.indices.contains(selectedIndex) else {
			return nil
		}

		return candidates[selectedIndex]
	}

	func show(_ candidates: [Candidate]) {
		self.candidates = candidates
		selectedIndex = 0
	}

	func clear() {
		candidates = []
		selectedIndex = 0
	}

	func moveDown() {
		guard !candidates.isEmpty else { return }
		selectedIndex = (selectedIndex + 1) % candidates.count
	}

	func moveUp() {
		guard !candidates.isEmpty else { return }
		selectedIndex = (selectedIndex - 1 + candidates.count) % candidates.count
	}
}

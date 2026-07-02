import Foundation

struct CandidateOption: Identifiable, Hashable {
	let id = UUID()
	let token: String
	let replacement: String
	let label: String
}

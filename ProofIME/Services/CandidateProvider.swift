import Foundation

final class CandidateProvider {

	func candidates(
		for candidate: TokenCandidate
	) -> [CandidateOption] {

		var options: [CandidateOption] = [
			CandidateOption(
				token: candidate.token,
				replacement: candidate.replacement,
				label: "default"
			)
		]

		switch candidate.token {
		case "fa":
			options.append(contentsOf: [
				CandidateOption(
					token: candidate.token,
					replacement: "∧",
					label: "and"
				),
				CandidateOption(
					token: candidate.token,
					replacement: "⇒",
					label: "implies"
				)
			])

		case "and":
			options.append(contentsOf: [
				CandidateOption(
					token: candidate.token,
					replacement: "∩",
					label: "intersection"
				),
				CandidateOption(
					token: candidate.token,
					replacement: "∧",
					label: "logical and"
				)
			])

		default:
			break
		}

		var seen = Set<String>()

		return options.filter { option in
			if seen.contains(option.replacement) {
				return false
			}

			seen.insert(option.replacement)
			return true
		}
	}
}

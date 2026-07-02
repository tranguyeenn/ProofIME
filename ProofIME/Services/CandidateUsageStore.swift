//
//  CandidateUsageStore.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/2/26.
//

import Foundation

final class CandidateUsageStore {

	private let key = "candidateUsageCounts"

	func usageCount(for replacement: String) -> Int {
		usageCounts()[replacement] ?? 0
	}

	func recordUse(of replacement: String) {
		var counts = usageCounts()

		counts[replacement, default: 0] += 1

		save(counts)
	}

	private func usageCounts() -> [String: Int] {
		guard let data = UserDefaults.standard.data(
			forKey: key
		) else {
			return [:]
		}

		return (
			try? JSONDecoder().decode(
				[String: Int].self,
				from: data
			)
		) ?? [:]
	}

	private func save(_ counts: [String: Int]) {
		guard let data = try? JSONEncoder().encode(counts) else {
			return
		}

		UserDefaults.standard.set(
			data,
			forKey: key
		)
	}
}

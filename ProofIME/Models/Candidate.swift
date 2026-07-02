//
//  Candidate.swift
//  ProofIME
//
//  Created by Trang Nguyen on 7/2/26.
//

import Foundation

struct Candidate: Identifiable, Hashable {
	let id = UUID()
	let text: String
	let label: String?
}

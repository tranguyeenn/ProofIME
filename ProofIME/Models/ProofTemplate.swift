//
//  ProofTemplate.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

struct ProofTemplate: Codable, Identifiable {
	let id: String
	let trigger: String
	let title: String
	let body: String
}

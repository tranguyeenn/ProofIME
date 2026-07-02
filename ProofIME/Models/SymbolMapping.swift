//
//  SymbolMapping.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

struct SymbolMapping: Identifiable {
	let id = UUID()
	let shortcut: String
	let symbol: String
}

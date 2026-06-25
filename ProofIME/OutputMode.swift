//
//  OutputMode.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

enum OutputMode: String, Codable, CaseIterable, Identifiable {
	case unicode = "Unicode"
	case latex = "LaTeX"

	var id: String { rawValue }
}

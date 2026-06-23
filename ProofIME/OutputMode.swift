//
//  OutputMode.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation

enum OutputMode: String, CaseIterable, Identifiable {
	case unicode = "Unicode"
	case latex = "LaTeX"

	var id: String { rawValue }
}

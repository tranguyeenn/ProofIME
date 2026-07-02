//
//  UTType+Tex.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import UniformTypeIdentifiers

extension UTType {
	static var tex: UTType {
		UTType(filenameExtension: "tex") ?? .plainText
	}
}

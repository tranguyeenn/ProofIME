//
//  AppConfig.swift
//  ProofIME
//
//  Created by Trang Nguyen on 6/23/26.
//

import Foundation
import AppKit

final class AppConfig {

	static let appFolderName = "ProofIME"

	static var configDirectory: URL {
		let base = FileManager.default.urls(
			for: .applicationSupportDirectory,
			in: .userDomainMask
		)[0]

		return base.appendingPathComponent(appFolderName)
	}

	static var userSymbolsURL: URL {
		configDirectory.appendingPathComponent("symbols.json")
	}

	static var userTemplatesURL: URL {
		configDirectory.appendingPathComponent("proof_templates.json")
	}

	static func ensureConfigDirectoryExists() {
		do {
			try FileManager.default.createDirectory(
				at: configDirectory,
				withIntermediateDirectories: true
			)
		} catch {
			print("Failed to create config directory:", error)
		}
	}

	static func openConfigDirectory() {
		ensureConfigDirectoryExists()
		NSWorkspace.shared.open(configDirectory)
	}

	static func deleteUserSymbols() {
		do {
			if FileManager.default.fileExists(atPath: userSymbolsURL.path) {
				try FileManager.default.removeItem(at: userSymbolsURL)
				print("Deleted custom symbols.json")
			}
		} catch {
			print("Failed to delete symbols.json:", error)
		}
	}

	static func deleteUserTemplates() {
		do {
			if FileManager.default.fileExists(atPath: userTemplatesURL.path) {
				try FileManager.default.removeItem(at: userTemplatesURL)
				print("Deleted custom proof_templates.json")
			}
		} catch {
			print("Failed to delete proof_templates.json:", error)
		}
	}
}

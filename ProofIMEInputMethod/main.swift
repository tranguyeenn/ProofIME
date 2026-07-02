import AppKit
import InputMethodKit

let connectionName = Bundle.main.object(forInfoDictionaryKey: "InputMethodConnectionName") as! String
let server = IMKServer(
	name: connectionName,
	bundleIdentifier: Bundle.main.bundleIdentifier
)

NSApplication.shared.run()

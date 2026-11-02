//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.Data
import class Foundation.FileHandle

package enum DiagnosticMode {
	case cli
	case xcode
}


package protocol DiagnosticCollector {
	var mode: DiagnosticMode { get }
	var verbosity: Diagnostic.Severity { get }
    func emit(_ diagnostic: Diagnostic)
	func describe(_ diagnostic: Diagnostic) -> String
}

package extension DiagnosticCollector {
	func canEmit(_ diagnostic: Diagnostic) -> Bool {
		diagnostic.severity <= verbosity
	}

	func describe(_ diagnostic: Diagnostic) -> String {
		var prefix = ""
		if let location = diagnostic.location {
			let filePath = switch mode {
			case .cli: location.file.lastPathComponent
			case .xcode: location.file.path()
			}
			prefix = "\(filePath):"
			if let line = location.line {
				prefix += "\(line):"
				if let column = location.column {
					prefix += "\(column):"
				}
			}
			prefix += " "
		}
		return "\(prefix)\(diagnostic.severity): \(diagnostic.message)"
	}
}

package protocol DiagnosticOutputHandle: Sendable {
	func write(_ data: Data)
}

extension FileHandle: DiagnosticOutputHandle {}

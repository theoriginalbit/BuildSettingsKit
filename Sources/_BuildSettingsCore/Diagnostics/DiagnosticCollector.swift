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
	var hasErrors: Bool { get }
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

	func notice(_ message: String, location: SourceLocation? = nil) {
		self.emit(.notice(message, location: location))
	}

	func info(_ message: String, location: SourceLocation? = nil) {
		self.emit(.info(message, location: location))
	}

	func warning(_ message: String, location: SourceLocation? = nil) {
		self.emit(.warning(message, location: location))
	}

	func error(_ message: String, location: SourceLocation? = nil) {
		self.emit(.error(message, location: location))
	}

	/// - Important: Emitting a fault will output the diagnostic and immediately exit the process
	func fault(_ message: String, location: SourceLocation? = nil) {
		self.emit(.fault(message, location: location))
	}
}

package protocol DiagnosticOutputHandle: Sendable {
	func write(_ data: Data)
}

extension FileHandle: DiagnosticOutputHandle {}

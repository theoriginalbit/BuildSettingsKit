//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation

package struct StdOutPrintingDiagnosticCollector<Output: DiagnosticOutputHandle>: DiagnosticCollector, Sendable {
	let output: Output
	package let mode: DiagnosticMode
	package let verbosity: Diagnostic.Severity

	package init(
		_ output: Output = FileHandle.standardOutput,
		diagnosticMode: DiagnosticMode = .cli,
		verbosity: Int,
	) {
		self.output = output
		self.mode = diagnosticMode
		self.verbosity = Diagnostic.Severity(verbosity: verbosity)
	}

	package func emit(_ diagnostic: Diagnostic) {
		guard canEmit(diagnostic) else { return }
		let message = describe(diagnostic) + "\n"
		output.write(Data(message.utf8))
	}
}

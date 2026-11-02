//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import class Foundation.FileHandle
import func Foundation.exit
import let Foundation.EXIT_FAILURE

package struct StandardDiagnosticCollector<StdOut: DiagnosticOutputHandle, StdErr: DiagnosticOutputHandle>: DiagnosticCollector, Sendable {
	package var mode: DiagnosticMode { stdOut.mode }

	package let verbosity: Diagnostic.Severity

	let stdOut: StdOutPrintingDiagnosticCollector<StdOut>
	let stdErr: StdErrPrintingDiagnosticCollector<StdErr>

	package init(
		stdOut: StdOut = FileHandle.standardOutput,
		stdErr: StdErr = FileHandle.standardError,
		diagnosticMode: DiagnosticMode,
		verbosity: Int,
	) {
		self.stdOut = .init(stdOut, diagnosticMode: diagnosticMode, verbosity: verbosity)
		self.stdErr = .init(stdErr, diagnosticMode: diagnosticMode, verbosity: verbosity)
		self.verbosity = Diagnostic.Severity(verbosity: verbosity)
	}

	package func emit(_ diagnostic: Diagnostic) {
		guard canEmit(diagnostic) else { return }

		switch diagnostic.severity {
		case .notice, .info, .warning:
			stdOut.emit(diagnostic)
		case .error:
			stdErr.emit(diagnostic)
		case .fault:
			stdErr.emit(diagnostic)
			exit(EXIT_FAILURE)
		}
	}
}

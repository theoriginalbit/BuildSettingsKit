//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

package struct QuietDiagnosticCollector: DiagnosticCollector {
	package let mode: DiagnosticMode
	package let verbosity: Diagnostic.Severity
	package func emit(_ diagnostic: Diagnostic) {}
}

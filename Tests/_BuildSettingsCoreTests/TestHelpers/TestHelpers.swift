//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
@testable import _BuildSettingsCore

final class TestDiagnosticCollector: DiagnosticCollector, @unchecked Sendable {
    let mode: DiagnosticMode
    var verbosity: Diagnostic.Severity
    var diagnostics: [Diagnostic] = []

    var hasErrors: Bool {
        return diagnostics.contains { $0.severity == .error }
    }

    var errors: [Diagnostic] {
        diagnostics.filter { $0.severity == .error }
    }

    var warnings: [Diagnostic] {
        diagnostics.filter { $0.severity == .warning }
    }

    var notices: [Diagnostic] {
        diagnostics.filter { $0.severity == .note }
    }

    var infos: [Diagnostic] {
        diagnostics.filter { $0.severity == .info }
    }

    init(mode: DiagnosticMode = .cli, verbosity: Diagnostic.Severity = .info) {
        self.mode = mode
        self.verbosity = verbosity
    }

    func emit(_ diagnostic: Diagnostic) {
        guard canEmit(diagnostic) else { return }
        diagnostics.append(diagnostic)
    }
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import _BuildSettingsCore

extension DiagnosticMode: EnumerableFlag {
	package static let allCases: [DiagnosticMode] = [.cli, .xcode]
}

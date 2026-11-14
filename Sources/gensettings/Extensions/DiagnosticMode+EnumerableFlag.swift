//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import _BuildSettingsCore
import ArgumentParser

extension DiagnosticMode: EnumerableFlag {
	package static let allCases: [DiagnosticMode] = [.cli, .xcode]
}

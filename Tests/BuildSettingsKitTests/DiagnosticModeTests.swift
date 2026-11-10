//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
import _BuildSettingsCore
@testable import BuildSettingsKit

@Suite struct DiagnosticModeTests {
	@Test func `Ensure DiagnosticMode.allCases returns all cases`() {
		#expect(DiagnosticMode.allCases == [.cli, .xcode])
    }
}

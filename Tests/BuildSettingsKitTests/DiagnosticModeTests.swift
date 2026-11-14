//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import _BuildSettingsCore
import Testing
@testable import gensettings

@Suite struct DiagnosticModeTests {
	@Test func `Ensure DiagnosticMode.allCases returns all cases`() {
		#expect(DiagnosticMode.allCases == [.cli, .xcode])
	}
}

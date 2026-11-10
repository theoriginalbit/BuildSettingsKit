//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation
import Testing
@testable import BuildSettingsKit

@Test func `URL ExpressibleByArgument conformance`() {
	let url = URL(argument: "/path/to/my/project")
	#expect(url != nil)
	#expect(url?.isFileURL == true)
	#expect(url?.path == "/path/to/my/project")
}

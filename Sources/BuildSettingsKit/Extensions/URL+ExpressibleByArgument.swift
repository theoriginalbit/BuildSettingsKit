//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import Foundation

extension URL: @retroactive ExpressibleByArgument {
	/// Initializes a `URL` instance using the path provided as an argument string.
	public init?(argument: String) {
		self.init(fileURLWithPath: argument)
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import _BuildSettingsCore

extension EnvironmentOverride: ExpressibleByArgument {
	package init?(argument: String) {
		let parts = argument.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
		guard parts.count == 2, !parts[0].isEmpty else {
			return nil
		}
		self.init(
			key: String(parts[0]),
			value: String(parts[1])
		)
	}
}

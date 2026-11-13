//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

struct EnvironmentOverride: CustomStringConvertible {
	let key: String
	let value: String

	var description: String {
		"\(key)=\(value)"
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

@testable import _BuildSettingsCore

extension SettingType: Equatable {
	public static func == (lhs: SettingType, rhs: SettingType) -> Bool {
		// define each explicitly with (.theCase, .theCase) and (.theCase, _)
		// never use default otherwise as new types are supported the compiler
		// will not complain about the lack of exhaustive checking here
		switch (lhs, rhs) {
		case (.string, .string): true
		case (.string, _): false
		case (.bool, .bool): true
		case (.bool, _): false
		case (.int, .int): true
		case (.int, _): false
		case (.double, .double): true
		case (.double, _): false
		case (.float, .float): true
		case (.float, _): false
		case (.url, .url): true
		case (.url, _): false
		case let (.array(lhs), .array(rhs)): lhs == rhs
		case (.array, _): false
		case let (.optional(lhs), .optional(rhs)): lhs == rhs
		case (.optional, _): false
		}
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation

enum PluginError: Error, LocalizedError {
	case incompatibleTarget(name: String)
	case configNotFound(targetName: String)
	case multipleConfigsFound(files: [URL], targetName: String)

	var errorDescription: String? {
		switch self {
		case let .incompatibleTarget(name):
			return "Incompatible target called '\(name)'. Only Swift source targets can be used with the BuildSettingsKit plugin."
		case let .configNotFound(targetName):
			return "No config file found in target '\(targetName)' or the root directory."
		case let .multipleConfigsFound(candidates, targetName):
			let list = candidates
				.map { "  - \($0)" }
				.joined(separator: "\n")
			return """
				Multiple config files found in target '\(targetName)', but exactly one is expected.
				\(list)
				Remove all but one.
				"""
		}
	}
}

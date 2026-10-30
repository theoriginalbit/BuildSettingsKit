//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

/// Top-level structure of `.buildsettings.yaml`.
package struct Configuration: Decodable {
	/// Name of the generated Swift file. Defaults to `"BuildSettings.swift"`.
	package let outputFileName: String?
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

/// Top-level structure of `.buildsettings.yaml`.
package struct Configuration: Decodable {
	/// Name of the generated Swift file. Defaults to `"BuildSettings.swift"`.
	@SourceLocatable
	package var outputFileName: String?

	/// Name of the enum namespace type to access the settings. Defaults to `"BuildSettings"`.
	@SourceLocatable
	package var typeName: String?

	@SourceLocatable
	package var settings: ConfigurationSettings
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//


package struct ConfigurationSetting: Decodable {
	@SourceLocatable
	package var key: String

	@SourceLocatable
	package var swiftName: String?
}
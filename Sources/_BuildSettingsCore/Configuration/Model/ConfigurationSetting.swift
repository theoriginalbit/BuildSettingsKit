//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//


package struct ConfigurationSetting: Decodable {
	/// The build setting to locate in the environment.
	@SourceLocatable
	package var key: String

	/// The member name to use in the generated code for this build setting.
	@SourceLocatable
	package var swiftName: String?

	/// The access modifier to attach to this specific setting's member. Defaults to configuration's root ``Configuration/accessModifier``.
	@SourceLocatable
	package var accessModifier: String?
}

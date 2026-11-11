//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

package struct ConfigurationSetting: Decodable {
	/// The build setting to locate in the environment.
	@SourceLocatable
	package var key: String

	/// Swift type of the value.
	@SourceLocatable
	package var type: String

	/// Swift type of the value.
	@SourceLocatable
	package var `default`: String?

	/// The member name to use in the generated code for this build setting.
	@SourceLocatable
	package var swiftName: String?

	/// The access modifier to attach to this specific setting's member. Defaults to configuration's root ``Configuration/accessModifier``.
	@SourceLocatable
	package var accessModifier: String?

	/// A DocC comment to attach to the member.
	@SourceLocatable
	package var comment: String?
}

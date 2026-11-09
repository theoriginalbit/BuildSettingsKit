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

	/// The access modifier to attach to the generated enum and members. Defaults to `internal`.
	@SourceLocatable
	package var accessModifier: String?

	/// A DocC comment to attach to the member.
	@SourceLocatable
	package var comment: String?

	/// The build settings to locate and generate members for.
	@SourceLocatable
	package var settings: ConfigurationSettings
}

package enum AccessModifier: String {
	case `public`
	case package
	case `internal`
	case `fileprivate`
	case `private`
}

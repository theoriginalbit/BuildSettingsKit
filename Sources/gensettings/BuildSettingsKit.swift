//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import Foundation
import _BuildSettingsCore

@main
struct BuildSettingsKit: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "gensettings",
		abstract: "Generate a type-safe Swift file from Xcode build settings.",
		discussion: """
			CONFIGURATION FILE

			  The config is a YAML file named one of:
			    \(ConfigDiscovery.supportedConfigFiles.formatted(.list(type: .or)))

			  Use `gensettings \(InitCommand.configuration.commandName!)` to create one.

			  TOP-LEVEL OPTIONS

			    settings         (required) List of build settings to generate. See below.
			    typeName         Name of the generated enum. Default: \(Defaults.typeName)
			    outputFileName   Name of the generated file. Default: \(Defaults.outputFileName)
			                     Ignored when --output is passed or when run as a plugin.
			    accessModifier   One of: \(AccessModifier.allCasesAsList). Default: internal
			    comment          DocC comment attached to the generated type.

			  SETTINGS OPTIONS

			    key              (required) Build setting name to read, e.g. MARKETING_VERSION.
			    type             (required) Swift type of the value. See below.
			    default          Value used when the key is missing from the environment.
			                     Not needed for optional types.
			    swiftName        Member name in the generated code. Required when the key
			                     can't be converted into a valid identifier.
			    accessModifier   Overrides the top-level accessModifier for this member.
			    comment          DocC comment attached to the member.

			  TYPES

			    Primitives       String, Bool, Int, Double, Float, URL
			    Arrays           '[T]' of any primitive type, e.g. '[String]'
			    Optional         T? of any primitive type, e.g. URL?

			    All types are matched case-insensitive

			  EXAMPLE

			    typeName: BuildConfig
			    settings:
			    - key: MARKETING_VERSION
				  type: String
			    - key: CURRENT_PROJECT_VERSION
				  swiftName: buildNumber
			      type: Int
			    - key: API_BASE_URL
			      type: URL?
			    - key: SUPPORTED_VERSIONS
			      type: '[Int]'

			""",
		version: toolVersion,
		subcommands: [GenerateCommand.self, InitCommand.self],
		defaultSubcommand: GenerateCommand.self,
	)
}

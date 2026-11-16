//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import Foundation
import _BuildSettingsCore

struct InitCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "init",
		abstract: "Create a starter configuration file.",
		discussion: "Run `gensettings help` to see everything the configuration supports.",
	)

	@Option(
		name: .shortAndLong,
		help: "Path for the new configuration file.",
		completion: .file(extensions: ["yaml", "yml"]),
	)
	private var output: URL? = nil

	@Flag(name: .shortAndLong, help: "Overwrite the file if it already exists.")
	private var force = false

	func run() throws {
		let fileManager = FileManager.default
		let url = output ?? URL(fileURLWithPath: fileManager.currentDirectoryPath)
			.appending(path: ConfigDiscovery.supportedConfigFiles[0], directoryHint: .notDirectory)

		if fileManager.fileExists(atPath: url.path(percentEncoded: false)), !force {
			throw ValidationError("\(url.lastPathComponent) already exists. Use --force to overwrite it.")
		}
		try Self.sample.write(to: url, atomically: true, encoding: .utf8)
		print("Created \(url.path(percentEncoded: false))")
	}

	/// A sample config. Optional top-level options are commented out so they can be discovered and enabled.
	static let sample = """
		# BuildSettingsKit configuration.
		# Run `gensettings help` for a full reference of the available options.

		# Name of the generated enum namespace. Defaults to "\(Defaults.typeName)".
		# typeName: \(Defaults.typeName)

		# Name of the generated file. Defaults to "\(Defaults.outputFileName)".
		# outputFileName: \(Defaults.outputFileName)

		# Access modifier for the generated type and members: \(AccessModifier.allCasesAsList).
		# Defaults to \(AccessModifier.internal.rawValue).
		# accessModifier: \(AccessModifier.internal.rawValue)

		# DocC comment attached to the generated type.
		# comment: Build settings generated from the Xcode project.

		settings:
		  - key: MARKETING_VERSION
			type: String
			comment: User-facing version string.

		 # Use swiftName when you want a different identifier to access the key, or
		 # the key can't be turned into a valid Swift identifier.
		 # - key: CURRENT_PROJECT_VERSION
		 #   swiftName: buildNumber
		 #   type: Int

		 # Optional types don't need to be present in the environment.
		 # - key: API_BASE_URL
		 #   type: URL?

		 # Or supply a default to use when the key is missing.
		 # - key: FEATURE_FLAG
		 #   type: Bool
		 #   default: "false"

		 # Or supply a default to use when the key is missing.
		 # - key: FEATURE_FLAG
		 #   type: Bool
		 #   default: "false"

		 # Declaring an array will split build settings on a space character
		 # - key: SUPPORTED_VERSIONS
		 #   type: '[Int]'

		"""
}

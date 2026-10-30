//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import struct Foundation.URL
import _BuildSettingsCore

struct GenerateCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "generate",
		abstract: "Generate a type-safe Swift file from Xcode build settings.",
	)

	@Option(
		name: .shortAndLong,
		help: ArgumentHelp(
			"Path to a YAML configuration file.",
			discussion: "If not provided the tool will attempt to auto-discover the configuration file.",
		),
		completion: .file(extensions: ["yaml", "yml"]),
	)
	private var config: URL?

	@Option(
		name: .shortAndLong,
		help: ArgumentHelp(
			"Path for the generated Swift file.",
			discussion: "If not provided it will be generated alongside the configuration file.",
		),
		completion: .file(extensions: ["swift"]),
	)
	private var output: URL?

	func run() throws {
		let configURL = try ConfigDiscovery.resolvedConfigURL(config)
		let config = try ConfigLoader.load(from: configURL)

		print("""

		Hello from the generate command

		- User supplied config: \(self.config?.path() ?? "<nil>")
		- Resolved config:      \(configURL.path())
		- Config:
		\(String(describing: config))
		- Output file:          \(resolvedOutputURL(relativeTo: configURL, using: config).path())
		""")
	}

	/// Returns the output URL, either from `--output` or derived from the config location.
	///
	/// When the config was auto-discovered and no `--output` was given, the
	/// generated file is placed alongside the config, using `outputFileName`
	/// from the YAML if present, or `"BuildSettings.swift"` as the default.
	/// We do a lightweight filename scan rather than a full YAML parse so
	/// that we don't duplicate the parse-then-generate pipeline.
	private func resolvedOutputURL(relativeTo configURL: URL, using config: Configuration) -> URL {
		if let output {
			return output
		}
		let outputFileName = config.outputFileName ?? "BuildSettings.swift"
		return configURL
			.deletingLastPathComponent()
			.appending(path: outputFileName, directoryHint: .notDirectory)
	}
}

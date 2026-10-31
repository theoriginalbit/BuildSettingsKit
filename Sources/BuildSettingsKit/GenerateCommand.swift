//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import struct Foundation.URL
import class Foundation.ProcessInfo
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

	@Option(
		name: .shortAndLong,
		parsing: .upToNextOption,
		help: ArgumentHelp(
			"Environment overrides. Passed as KEY=VALUE pairs.",
			discussion: "Merged with, and taking precedence over, the process environment.",
			valueName: "KEY=VALUE",
		),
	)
	private var env: [EnvironmentOverride]

	func run() throws {
		let configURL = try ConfigDiscovery.resolvedConfigURL(config)
		let config = try ConfigLoader.load(from: configURL)
		let outputURL = resolvedOutputURL(relativeTo: configURL, using: config)

		print("""

		Hello from the generate command

		- User supplied config: \(self.config?.path() ?? "<nil>")
		- Resolved config:      \(configURL.path())
		- Env overrides:        \(env.map(String.init(describing:)).joined(separator: ", "))
		- Resolved env:
		\(
			resolvedEnvironment().sorted { $0.key < $1.key }
				.map { "\t\($0.key)=\($0.value)" }
				.joined(separator: "\n")
		)
		- Config:
		\(String(describing: config))
		- Output file:          \(outputURL.path())
		""")
	}

	/// Returns the output URL, either from `--output` or derived from the config location.
	///
	/// When the config was auto-discovered and no `--output` was given, the
	/// generated file is placed alongside the config, using `outputFileName`
	/// from the YAML if present, or `"BuildSettings.swift"` as the default.
	private func resolvedOutputURL(relativeTo configURL: URL, using config: Configuration) -> URL {
		if let output {
			return output
		}
		let outputFileName = config.outputFileName ?? "BuildSettings.swift"
		return configURL
			.deletingLastPathComponent()
			.appending(path: outputFileName, directoryHint: .notDirectory)
	}

	private func resolvedEnvironment() -> [String: String] {
		var environment = ProcessInfo.processInfo.environment
		for override in env {
			environment[override.key] = override.value
		}
		return environment
	}
}

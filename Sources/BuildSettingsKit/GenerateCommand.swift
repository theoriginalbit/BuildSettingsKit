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

	@Flag(
		exclusivity: .exclusive,
		help: ArgumentHelp(
			"Show diagnostic messages with short filenames (best for CLI) or long file paths for Xcode's issue navigator to annotate (best for parsing.)"
		),
	)
	private var diagnosticMode: DiagnosticMode = .cli

	@Flag(name: .shortAndLong, help: "Increase verbosity (-vvv).")
	private var verbose: Int

	func run() throws {
		let configURL = try ConfigDiscovery.resolvedConfigURL(config)
		let config = try ConfigLoader.load(from: configURL)
		let env = resolvedEnvironment()

		let diagnosticsCollector = StandardDiagnosticCollector(
			diagnosticMode: diagnosticMode,
			verbosity: verbose,
		)

		let generator = CodeGenerator(
			environment: env,
			config: config,
			configURL: configURL,
			outputURL: output,
		)
		generator.run(diagnosticsCollector)
	}

	private func resolvedEnvironment() -> [String: String] {
		var environment = ProcessInfo.processInfo.environment
		for override in env {
			environment[override.key] = override.value
		}
		return environment
	}
}

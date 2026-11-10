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

		let context = CodeGenerator.Context(
			environment: env,
			config: config,
			outputURL: resolvedOutputURL(relativeTo: configURL, using: config),
			diagnostics: diagnosticsCollector,
		)
		let generator = CodeGenerator()
		do {
			try generator.run(with: context)
		} catch let error as GeneratorError where error.stage == .generation {
			// there was an error during generation, there will be diagnostics already
			// so just throw failure so there isn't a double printout of the error
			throw ExitCode.failure
		}
	}

	private func resolvedEnvironment() -> [String: String] {
		var environment = ProcessInfo.processInfo.environment
		for override in env {
			environment[override.key] = override.value
		}
		return environment
	}

	/// Returns an output URL alongside the config location.
	///
	/// The filename will be read from the config value ``Configuration/outputFileName`` or default to `BuildSettings.swift`.
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

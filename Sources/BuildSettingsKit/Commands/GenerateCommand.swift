//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser
import Foundation
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
		name: [.short, .customLong("output"), .long],
		help: ArgumentHelp(
			"Path for the generated Swift file.",
			discussion: "If not provided it will be generated in the current working directory as \(Constants.outputFileName).",
		),
		completion: .file(extensions: ["swift"]),
	)
	private var outputFile: URL?

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

	@Flag(
		name: .customLong("build-tool"),
		inversion: .prefixedNo,
		exclusivity: .chooseLast,
		help: .private
	)
	private var isRunningAsBuildTool: Bool

	@Flag(name: .shortAndLong, help: "Increase verbosity (-vvv).")
	private var verbose: Int

	func run() throws {
		do {
			let configURL = try resolveConfig()
			let config = try ConfigLoader.load(from: configURL)
			let env = resolvedEnvironment()

			let diagnostics = StandardDiagnosticCollector(mode: diagnosticMode, verbosity: verbose)
			let output = try resolvedOutputURL(using: config, diagnostics: diagnostics)

			let context = CodeGenerator.Context(
				environment: env,
				config: config,
				outputURL: output,
				diagnostics: diagnostics,
			)

			let generator = CodeGenerator()
			try generator.run(with: context)
		} catch let error as GeneratorError where error.alreadyLogged {
			// there was an error but it reports there will already be diagnostics
			// so just throw failure so there isn't a double printout of the error
			throw ExitCode.failure
		}
	}

	private func resolveConfig(fileManager: FileManager = .default) throws -> URL {
		if let config {
			// use the user supplied
			return config
		}
		// See if the config is in the CWD
		let dir = URL(fileURLWithPath: fileManager.currentDirectoryPath)
		let contents = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey])
		return try ConfigDiscovery.locateConfig(in: contents)
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
	private func resolvedOutputURL(using config: Configuration, diagnostics: some DiagnosticCollector) throws(GeneratorError) -> URL {
		if let outputFile {
			if config.outputFileName != nil {
				let message = if isRunningAsBuildTool {
					"'outputFileName' has no effect when running as a build tool."
				} else {
					"Output file path argument was supplied, outputFileName will be ignored."
				}
				diagnostics.note(
					message,
					location: config.$outputFileName,
				)
			}
			return outputFile
		}
		if isRunningAsBuildTool {
			diagnostics.error(
				"internal error: running as build tool but output file path is missing.",
				location: config.$outputFileName,
			)
			throw .specifyOutputPath
		}
		let outputFileName = config.outputFileName ?? Constants.outputFileName
		return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
			.appending(path: outputFileName, directoryHint: .notDirectory)
	}
}

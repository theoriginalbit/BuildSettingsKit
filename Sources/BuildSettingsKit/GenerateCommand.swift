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
	var config: URL?

	func run() throws {
		print("Hello from the generate command")
		print("User supplied config:", config?.path() ?? "<nil>")

		let configURL = try ConfigDiscovery.resolvedConfigURL(config)
		print("Resolved config:", configURL.path())
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import ArgumentParser

@main
struct BuildSettingsKit: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "gensettings",
		abstract: "Generate a type-safe Swift file from Xcode build settings.",
		subcommands: [GenerateCommand.self],
		defaultSubcommand: GenerateCommand.self
	)
}

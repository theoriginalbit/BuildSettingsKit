//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL

package struct CodeGenerator {
	let environment: [String: String]
	let config: Configuration
	let outputURL: URL

	package init(environment: [String: String], config: Configuration, configURL: URL, outputURL: URL?) {
		self.environment = environment
		self.config = config
		self.outputURL = outputURL ?? Self.resolvedOutputURL(relativeTo: configURL, using: config)
	}

	package func run(_ diagnostics: some DiagnosticCollector) {
		diagnostics.emit(.info("Output file: \(outputURL.path())"))

		if config.settings.isEmpty {
			diagnostics.emit(.error("Must supply at least one setting to codegen", location: config.$settings))
		}
		for setting in config.settings {
			guard let value = environment[setting.key] else {
				diagnostics.emit(.error(
					"No matching key in environment: '\(setting.key)'",
					location: setting.$key
				))
				continue
			}
			diagnostics.emit(.info("Key '\(setting.key)' found: '\(value)'"))
		}


	}

	/// Returns an output URL alongside the config location.
	///
	/// The filename will be read from the config value ``Configuration/outputFileName`` or default to `BuildSettings.swift`.
	private static func resolvedOutputURL(relativeTo configURL: URL, using config: Configuration) -> URL {
		let outputFileName = config.outputFileName ?? "BuildSettings.swift"
		return configURL
			.deletingLastPathComponent()
			.appending(path: outputFileName, directoryHint: .notDirectory)
	}
}

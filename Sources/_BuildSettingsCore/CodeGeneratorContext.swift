//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL

package extension CodeGenerator {
	struct Context<Diagnostics: DiagnosticCollector> {
		let environment: [String: String]
		let config: Configuration
		let outputURL: URL
		let verbosity: Int
		let diagnostics: Diagnostics

		package init(
			environment: [String : String],
			config: Configuration,
			outputURL: URL,
			verbosity: Int,
			diagnostics: Diagnostics
		) {
			self.environment = environment
			self.config = config
			self.outputURL = outputURL
			self.verbosity = verbosity
			self.diagnostics = diagnostics
		}
	}
}

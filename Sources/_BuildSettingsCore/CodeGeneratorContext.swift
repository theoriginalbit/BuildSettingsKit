//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL

package extension CodeGenerator {
	struct Context<Diagnostics: DiagnosticCollector> {
		let environment: [String: String]
		let config: Configuration
		let outputURL: URL
		let diagnostics: Diagnostics

		package init(
			environment: [String : String],
			config: Configuration,
			outputURL: URL,
			diagnostics: Diagnostics
		) {
			self.environment = environment
			self.config = config
			self.outputURL = outputURL
			self.diagnostics = diagnostics
		}
	}
}

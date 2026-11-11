//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation
import Testing
@testable import _BuildSettingsCore

@Suite struct GeneratorErrorTests {
	@Test func `missing config error output`() {
		let error = GeneratorError.missingConfigFile(path: "/path/to/missing.yaml")
		#expect(error.stage == .config)
		#expect(error.description == "Configuration file '/path/to/missing.yaml' does not exist.")
	}

	@Test func `ambiguous config error output`() {
		let error = GeneratorError.ambiguousConfig(candidates: ["conf1.yaml", "conf2.yaml"])
		#expect(error.stage == .config)
		#expect(error.description == """
			BuildSettingsKit: Multiple configuration files found.
			Use --config to specify which one to use:
			  - conf1.yaml
			  - conf2.yaml
			""")
	}

	@Test func `no config error output`() {
		let error = GeneratorError.noConfigFound(searchRoot: "/root/dir")
		#expect(error.stage == .config)
		#expect(error.description == "No configuration file found. Provide --config argument or add a configuration file in '/root/dir'.")
	}

	@Test func `empty config error output`() {
		let error = GeneratorError.emptyConfigFile(URL(fileURLWithPath: "/path/empty.yaml"))
		#expect(error.stage == .config)
		#expect(error.description == "Configuration file cannot be empty.")
	}

	@Test func `invalid config error output`() {
		let nestedError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Disk failure"])
		let error = GeneratorError.invalidConfigFile(URL(fileURLWithPath: "/path"), error: nestedError)
		#expect(error.stage == .config)
		#expect(error.description == "Failed to parse configuration file: Disk failure.")
	}

	@Test func `generation failed error output`() {
        let error = GeneratorError.generationFailed
        #expect(error.stage == .generation)
        #expect(error.description == "Code generation failed due to previous errors.")
    }
}

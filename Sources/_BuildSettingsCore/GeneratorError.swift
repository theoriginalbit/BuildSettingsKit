//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

package struct GeneratorError: Error, CustomStringConvertible {
	package let description: String

	private init(_ description: String) {
		self.description = description
	}
}

package extension GeneratorError {
	@inlinable
	static func missingConfigFile(path: String) -> Self {
		GeneratorError("error: BuildSettingsKit configuration file not found at \(path).")
	}

	@inlinable
	static func ambiguousConfig(candidates: [String]) -> Self {
		let list = candidates
			.map { "  \($0)" }
			.joined(separator: "\n")

		return GeneratorError(
			"""
			error: BuildSettingsKit: Multiple configuration files found.
			Use --config to specify which one to use:
			\(list)
			"""
		)
	}

	@inlinable
	static func noConfigFound(searchRoot: String) -> Self {
		GeneratorError("error: No configuration file not found. Provide --config argument or add a configuration file in \(searchRoot).")
	}
}

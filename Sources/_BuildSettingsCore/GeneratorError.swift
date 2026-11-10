//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL

package struct GeneratorError: Error, Equatable, CustomStringConvertible {
	package enum Stage {
		case config
		case generation
	}

	package let stage: Stage
	package let description: String

	private init(stage: Stage, message description: String) {
		self.stage = stage
		self.description = description
	}
}

package extension GeneratorError {
	@inlinable
	static func missingConfigFile(path: String) -> Self {
		GeneratorError(stage: .config, message: "Configuration file '\(path)' does not exist.")
	}

	@inlinable
	static func ambiguousConfig(candidates: [String]) -> Self {
		let list = candidates
			.map { "  - \($0)" }
			.joined(separator: "\n")

		return GeneratorError(
			stage: .config,
			message: """
			BuildSettingsKit: Multiple configuration files found.
			Use --config to specify which one to use:
			\(list)
			"""
		)
	}

	@inlinable
	static func noConfigFound(searchRoot: String) -> Self {
		GeneratorError(
			stage: .config,
			message: "No configuration file not found. Provide --config argument or add a configuration file in '\(searchRoot)'."
		)
	}

	@inlinable
	static func emptyConfigFile(_ file: URL) -> Self {
		GeneratorError(stage: .config, message: "Configuration file cannot be empty.")
	}

	@inlinable
	static func invalidConfigFile(_ file: URL, error: some Error) -> Self {
		GeneratorError(
			stage: .config,
			message: "Failed to parse configuration file: \(error.localizedDescription)."
		)
	}

	@inlinable
	static func invalidConfigFile(_ file: URL, error: DecodingError) -> Self {
		GeneratorError(
			stage: .config,
			message: "Failed to parse configuration file: \(error.friendlyDescription)."
		)
	}

	static let generationFailed = GeneratorError(stage: .generation, message: "Code generation failed due to previous errors.")
}

extension DecodingError {
	var failingPath: [CodingKey] {
		switch self {
		case let .keyNotFound(key, context):
			context.codingPath + CollectionOfOne(key)
		case let .valueNotFound(_, context),
			let .typeMismatch(_, context),
			let .dataCorrupted(context):
			context.codingPath
		@unknown default:
			[]
		}
	}

	var friendlyDescription: String {
		func path(_ context: Context) -> String {
			return context.codingPath.reduce("root") { result, nextKey in
				if let intValue = nextKey.intValue {
					return "\(result)[\(intValue)]"
				}
				return "\(result).\(nextKey.stringValue)"
			}
		}

		switch self {
		case let .keyNotFound(key, context):
			let parent = path(context)
			return "Missing required key '\(key.stringValue)' at \(parent)"

		case let .valueNotFound(type, context):
			return "Expected \(type) but found null at \(path(context))"

		case let .typeMismatch(type, context):
			return "Type mismatch at \(path(context)): expected \(type)"

		case let .dataCorrupted(context):
			return "Invalid data at \(path(context)): \(context.debugDescription)"

		@unknown default:
			return String(describing: self)
		}
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL

package struct GeneratorError: Error, CustomStringConvertible {
	package let description: String

	private init(_ description: String) {
		self.description = description
	}
}

package extension GeneratorError {
	@inlinable
	static func missingConfigFile(path: String) -> Self {
		GeneratorError("Configuration file '\(path)' does not exist.")
	}

	@inlinable
	static func ambiguousConfig(candidates: [String]) -> Self {
		let list = candidates
			.map { "  \($0)" }
			.joined(separator: "\n")

		return GeneratorError(
			"""
			BuildSettingsKit: Multiple configuration files found.
			Use --config to specify which one to use:
			\(list)
			"""
		)
	}

	@inlinable
	static func noConfigFound(searchRoot: String) -> Self {
		GeneratorError("No configuration file not found. Provide --config argument or add a configuration file in '\(searchRoot)'.")
	}

	@inlinable
	static func emptyConfigFile(_ file: URL) -> Self {
		GeneratorError("Configuration file cannot be empty.")
	}

	@inlinable
	static func invalidConfigFile(_ file: URL, error: some Error) -> Self {
		GeneratorError("Failed to parse configuration file: \(error.localizedDescription).")
	}

	@inlinable
	static func invalidConfigFile(_ file: URL, error: DecodingError) -> Self {
		GeneratorError("Failed to parse configuration file: \(error.friendlyDescription).")
	}
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

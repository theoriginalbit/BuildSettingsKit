//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import enum Yams.Node
import struct Foundation.URL

@propertyWrapper
package struct SourceLocatable<Value>: CustomStringConvertible {
	package let wrappedValue: Value

	private let sourceLocation: SourceLocation?

	package var projectedValue: SourceLocation? {
		sourceLocation
	}

	package var description: String {
		if let sourceLocation {
			"\(wrappedValue) [\(sourceLocation)]"
		} else {
			String(describing: wrappedValue)
		}
	}

	package init(wrappedValue value: Value) {
		wrappedValue = value
		sourceLocation = nil
	}

	package init(wrappedValue value: Value, location: SourceLocation?) {
		wrappedValue = value
		sourceLocation = location
	}
}

extension SourceLocatable: Decodable where Value: Decodable {
	package init(from decoder: any Decoder) throws {
		let value = try decoder.singleValueContainer().decode(Value.self)
		var location: SourceLocation?
		if let file = decoder.userInfo[.sourceFile] as? URL {
			var line, column: Int?
			if let root = decoder.userInfo[.yamlRoot] as? Node, let mark = root.node(at: decoder.codingPath)?.mark {
				line = mark.line
				column = mark.column
			}
			location = SourceLocation(file: file, line: line, column: column)
		}
		self.init(wrappedValue: value, location: location)
	}
}

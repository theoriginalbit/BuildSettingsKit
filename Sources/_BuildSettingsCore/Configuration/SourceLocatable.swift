//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Yams

@propertyWrapper
package struct SourceLocatable<Value>: CustomStringConvertible {
	package let wrappedValue: Value

	private let sourceLocation: DiagnosticSourceLocation?

	package var projectedValue: DiagnosticSourceLocation? {
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

	package init(wrappedValue value: Value, location: DiagnosticSourceLocation?) {
		wrappedValue = value
		sourceLocation = location
	}
}

extension SourceLocatable: Decodable where Value: Decodable {
	package init(from decoder: any Decoder) throws {
		let value = try decoder.singleValueContainer().decode(Value.self)
		var location: DiagnosticSourceLocation?
		if let root = decoder.userInfo[.yamlRoot] as? Node, let mark = root.node(at: decoder.codingPath)?.mark {
			location = DiagnosticSourceLocation(line: mark.line, column: mark.column)
		}
		self.init(wrappedValue: value, location: location)
	}
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL
import enum Yams.Node

package struct ConfigurationSettings: RandomAccessCollection, Decodable {
	private var _storage: [ConfigurationSetting]

	let location: SourceLocation?

	package var startIndex: Int {
		_storage.startIndex
	}

	package var endIndex: Int {
		_storage.endIndex
	}

	package subscript(position: Int) -> ConfigurationSetting {
		_storage[position]
	}

	package init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()

		let location: SourceLocation?
		if let file = decoder.userInfo[.sourceFile] as? URL {
			var line, column: Int?
			if let root = decoder.userInfo[.yamlRoot] as? Node, let mark = root.node(at: decoder.codingPath)?.mark {
				line = mark.line
				column = mark.column
			}
			location = SourceLocation(file: file, line: line, column: column)
		} else {
			location = nil
		}
		self.location = location

		if container.decodeNil() {
			if location == nil {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "Must specify at least one setting")
			}
			// we have a location, let the generator emit a diagnostic that it cannot be empty
			_storage = []
		} else {
			_storage = try container.decode([ConfigurationSetting].self)
		}
	}
}

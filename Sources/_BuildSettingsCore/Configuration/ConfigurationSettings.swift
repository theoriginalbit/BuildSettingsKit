//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//


package struct ConfigurationSettings: RandomAccessCollection, Decodable {
	package var settings: [ConfigurationSetting]

	package var startIndex: Int {
		settings.startIndex
	}

	package var endIndex: Int {
		settings.endIndex
	}

	package subscript(position: Int) -> ConfigurationSetting {
		settings[position]
	}

	package init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		if container.decodeNil() {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Must specify at least one setting")
		} else {
			settings = try container.decode([ConfigurationSetting].self)
		}
	}
}
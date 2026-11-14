//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

indirect enum SettingType: Sendable, Decodable {
	case string
	case bool
	case int
	case double
	case url
	case array(SettingType)
	case optional(SettingType)

	init?(parsing rawValue: String) {
		if let primitive = Primitive(rawValue: rawValue) {
			self = switch primitive {
			case .string: .string
			case .bool: .bool
			case .int: .int
			case .double: .double
			case .url: .url
			}
		} else if rawValue.hasSuffix("?") { // parse ? first because it's imbalanced
			let inner = String(rawValue.dropLast())
			guard let element = Self(parsing: inner) else { return nil }
			self = .optional(element)
		} else if rawValue.hasPrefix("["), rawValue.hasSuffix("]") {
			let inner = String(rawValue.dropFirst().dropLast())
			guard let element = Self(parsing: inner) else { return nil }
			self = .array(element)
		} else {
			return nil
		}
	}

	private enum Primitive: String {
		case string = "String"
		case bool = "Bool"
		case int = "Int"
		case double = "Double"
		case url = "URL"
	}
}

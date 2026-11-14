//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
@testable import _BuildSettingsCore

@Suite struct SettingTypeParsingTests {
	@Test(arguments: [
		("String", SettingType.string),
		("string", .string),
		("Bool", .bool),
		("bool", .bool),
		("Int", .int),
		("int", .int),
		("Double", .double),
		("double", .double),
		("URL", .url),
		("url", .url),
	]) func `parses primitives`(rawValue: String, expected: SettingType) {
		#expect(SettingType(parsing: rawValue) == expected)
	}

	@Test func `parses array`() {
		#expect(SettingType(parsing: "[Int]") == .array(.int))
	}

	@Test func `parses nested array`() {
		#expect(SettingType(parsing: "[[String]]") == .array(.array(.string)))
	}

	@Test(arguments: [
		"",
		"CustomType",
		"[",
		"]",
		"[]",
		"[CustomType]",
		"[[Int]",
		"Int]",
	]) func `rejects invalid`(raw: String) {
		#expect(SettingType(parsing: raw) == nil)
	}
}

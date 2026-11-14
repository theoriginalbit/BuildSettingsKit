//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
@testable import _BuildSettingsCore

@Suite struct SettingTypeParsingTests {
	@Test(arguments: [
		("String", SettingType.string),
		("Bool", .bool),
		("Int", .int),
		("Double", .double),
		("URL", .url),
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
		"string",
		"Float",
		"[",
		"]",
		"[]",
		"[Float]",
		"[[Int]",
		"Int]",
	]) func `rejects invalid`(raw: String) {
		#expect(SettingType(parsing: raw) == nil)
	}
}

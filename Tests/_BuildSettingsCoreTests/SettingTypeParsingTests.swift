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
	]) func parsesPrimitives(rawValue: String, expected: SettingType) {
		#expect(SettingType(parsing: rawValue) == expected)
	}

	@Test func parsesArray() {
		#expect(SettingType(parsing: "[Int]") == .array(.int))
	}

	@Test func parsesNestedArray() {
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
	]) func rejectsInvalid(raw: String) {
		#expect(SettingType(parsing: raw) == nil)
	}
}

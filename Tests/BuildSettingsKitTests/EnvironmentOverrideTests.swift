//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
@testable import BuildSettingsKit

@Suite struct EnvironmentOverrideTests {
	@Test func `Parsing a simple key value pair`() {
		let value = EnvironmentOverride(argument: "FOO=BAR")
		#expect(value?.key == "FOO")
		#expect(value?.value == "BAR")
		#expect(value?.description == "FOO=BAR")
	}

	@Test func `Parsing a key value pair with no value`() {
		let value = EnvironmentOverride(argument: "KEY=")
		#expect(value?.key == "KEY")
		#expect(value?.value == "")
		#expect(value?.description == "KEY=")
	}

	@Test func `Parsing a basic URL`() {
		let value = EnvironmentOverride(argument: "BASE_URL=https://example.com")
		#expect(value?.key == "BASE_URL")
		#expect(value?.value == "https://example.com")
	}

	@Test func `Parsing a URL with a query resulting in multiple = signs`() {
		let multipleEquals = EnvironmentOverride(argument: "BASE_URL=https://example.com?a=b")
		#expect(multipleEquals?.key == "BASE_URL")
		#expect(multipleEquals?.value == "https://example.com?a=b")
		#expect(multipleEquals?.description == "BASE_URL=https://example.com?a=b")
	}
}

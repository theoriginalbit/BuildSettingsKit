//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Testing
@testable import _BuildSettingsCore

@Suite struct IdentifierTests {
    @Test func `init with valid string`() {
        let identifier = Identifier("validName")
        #expect(identifier != nil)
        #expect(identifier?.value == "validName")
    }

	@Test func `init with invalid string`() {
		let invalid = Identifier("123invalid")
		#expect(invalid == nil)
	}

	static let validIdentifiers = ["myVariable", "MyClass", "_privateVar", "var123", "camelCase", "PascalCase", "_", "_123"]
	@Test(arguments: Self.validIdentifiers) func `valid identifiers`(_ candidate: String) {
        #expect(Identifier.isValid(candidate))
    }

	static let invalidIdentifiers = ["", "123var", "my-var", "my variable", "foo.bar", "@property"]
	@Test(arguments: Self.invalidIdentifiers) func `invalid identifiers`(_ candidate: String) {
        #expect(Identifier.isValid(candidate) == false)
    }

	static let keywords = [
		"associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
		"init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup",
		"protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var",
		"break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough",
		"for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while",
		"Any", "as", "await", "false", "is", "nil", "self", "Self", "super", "throws", "true", "try",
	]
	@Test(arguments: Self.keywords) func `keywords are invalid only as bare keywords`(_ keyword: String) {
		#expect(Identifier.isValid(keyword) == false)
		#expect(Identifier.isValid("`\(keyword)`"))
    }

	static let rawIdentifiersValidity = [
		("`default`", true), ("`class`", true), ("`self`", true), ("`123invalid`", true),
		("`my-var`", true), ("``", false), ("` `", false), ("`   `", false), ("`", false),
		("`test", false), ("test`", false), ("`test\\`", false), ("`test`extra`", false),
	]
	@Test(arguments: Self.rawIdentifiersValidity) func `raw identifiers allow some invalid to pass`(_ candidate: String, isValid: Bool) {
        #expect(Identifier.isValid(candidate) == isValid)
    }

	@Test func `type identifier follows type naming convention`() throws {
		let typeId = try #require(Identifier("MySettings"))
		#expect(typeId.followsNamingConvention(.typeName))
		#expect(typeId.followsNamingConvention(.memberName) == false)
	}

	@Test func `member identifier follows member naming convention`() throws {
		let memberId = try #require(Identifier("apiKey"))
		#expect(memberId.followsNamingConvention(.typeName) == false)
		#expect(memberId.followsNamingConvention(.memberName))
	}

	@Test func `raw identifier follows both type and member naming conventions`() throws {
        let rawId = try #require(Identifier("`any_name`"))
        #expect(rawId.followsNamingConvention(.typeName))
        #expect(rawId.followsNamingConvention(.memberName))
    }

	static let camelCaseConversionTable = [
		("", nil), ("MARKETING_VERSION", "marketingVersion"),
		("PRODUCT_BUNDLE_IDENTIFIER", "productBundleIdentifier"),
		("SINGLE", "single"), ("already_camel_case", "alreadyCamelCase"),
		("UPPER_AND_LOWER_mixed", "upperAndLowerMixed"), ("FOO__BAR", "fooBar"),
	]
	@Test(arguments: Self.camelCaseConversionTable) func `camelCased conversion`(_ input: String, _ expected: String?) {
		#expect(Identifier.camelCased(input)?.value == expected)
    }
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation
import Testing
@testable import _BuildSettingsCore

@Suite struct ConfigLoaderTests {
    @Test func `Loading empty file throws emptyConfigFile`() throws {
		let tempDir = try TempDir.create()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let emptyFile = tempDir.appending(path: "empty.yaml")
        try "".write(to: emptyFile, atomically: true, encoding: .utf8)

        #expect(throws: GeneratorError.self) {
            try ConfigLoader.load(from: emptyFile)
        }
    }

	@Test func `Loading whitespace-only file throws emptyConfigFile`() throws {
		let tempDir = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: tempDir) }

		let whitespaceFile = tempDir.appending(path: "spaces.yaml")
		try "   \n\t  \n".write(to: whitespaceFile, atomically: true, encoding: .utf8)

		#expect(throws: GeneratorError.self) {
			try ConfigLoader.load(from: whitespaceFile)
		}
	}

    @Test func `Loading invalid YAML syntax throws invalidConfigFile`() throws {
		let tempDir = try TempDir.create()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let invalidFile = tempDir.appending(path: "invalid.yaml")
        try ": this is not : valid: [yaml".write(to: invalidFile, atomically: true, encoding: .utf8)

        #expect(throws: GeneratorError.self) {
            try ConfigLoader.load(from: invalidFile)
        }
    }

    @Test func `Loading valid configuration successfully parses all fields`() throws {
        let yaml = """
        outputFileName: CustomSettings.swift
        typeName: AppSettings
        accessModifier: public
        comment: Configuration generated for the app

        settings:
          - key: APP_NAME
            type: String
            swiftName: name
            accessModifier: package
            comment: The application display name
          - key: DEBUG_MODE
            type: Bool
          - key: MAX_CONNECTIONS
            type: Int
        """

		let tempDir = try TempDir.create()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let configFile = tempDir.appending(path: "buildsettings.yaml")
        try yaml.write(to: configFile, atomically: true, encoding: .utf8)

        let config = try ConfigLoader.load(from: configFile)

		func expectLocation(
			_ location: _BuildSettingsCore.SourceLocation?,
			line: Int,
			column: Int,
			sourceLocation: Testing.SourceLocation = #_sourceLocation
		) {
			#expect(location?.file == configFile, sourceLocation: sourceLocation)
			#expect(location?.line == line, sourceLocation: sourceLocation)
			#expect(location?.column == column, sourceLocation: sourceLocation)
		}

        #expect(config.outputFileName == "CustomSettings.swift")
		expectLocation(config.$outputFileName, line: 1, column: 17)
        #expect(config.typeName == "AppSettings")
		expectLocation(config.$typeName, line: 2, column: 11)
        #expect(config.accessModifier == "public")
		expectLocation(config.$accessModifier, line: 3, column: 17)
        #expect(config.comment == "Configuration generated for the app")
		expectLocation(config.$comment, line: 4, column: 10)

        #expect(config.settings.count == 3)

        let first = config.settings[0]
        #expect(first.key == "APP_NAME")
		expectLocation(first.$key, line: 7, column: 10)
        #expect(first.type == "String")
		expectLocation(first.$type, line: 8, column: 11)
        #expect(first.swiftName == "name")
		expectLocation(first.$swiftName, line: 9, column: 16)
        #expect(first.accessModifier == "package")
		expectLocation(first.$accessModifier, line: 10, column: 21)
        #expect(first.comment == "The application display name")
		expectLocation(first.$comment, line: 11, column: 14)

        let second = config.settings[1]
        #expect(second.key == "DEBUG_MODE")
		expectLocation(second.$key, line: 12, column: 10)
        #expect(second.type == "Bool")
		expectLocation(second.$type, line: 13, column: 11)
        #expect(second.swiftName == nil)
        #expect(second.accessModifier == nil)
		#expect(second.comment == nil)

        let third = config.settings[2]
        #expect(third.key == "MAX_CONNECTIONS")
		expectLocation(third.$key, line: 14, column: 10)
        #expect(third.type == "Int")
		expectLocation(third.$type, line: 15, column: 11)
		#expect(second.swiftName == nil)
		#expect(second.accessModifier == nil)
		#expect(second.comment == nil)
    }
}

//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation
import Testing
@testable import _BuildSettingsCore

@Suite struct ConfigDiscoveryTests {
	static let acceptedFileNames = [
		"buildsettings.yaml", "buildsettings.yml", ".buildsettings.yaml",
		".buildsettings.yml", "BUILDSETTINGS.YAML", "BuildSettings.yml",
	]
	@Test(arguments: Self.acceptedFileNames) func `Accepted file names`(_ candidate: String) {
		#expect(ConfigDiscovery.isAcceptedFileName(URL(fileURLWithPath: candidate)))
    }

	static let rejectedFileNames = [
		"settings.yaml", "build.yml", "buildsettings.json", "other.swift", "_buildsettings.yaml",
	]
	@Test(arguments: Self.rejectedFileNames) func `Rejected file names`(_ candidate: String) {
		#expect(ConfigDiscovery.isAcceptedFileName(URL(fileURLWithPath: candidate)) == false)
	}

    @Test func `Search in directory, nothing found`() throws {
		let tempDir = try TempDir.create()
        defer { try? FileManager.default.removeItem(at: tempDir) }

		let manager = FileManager()
		manager.changeCurrentDirectoryPath(tempDir.path())

        let result = ConfigDiscovery.search(from: tempDir, fileManager: manager)
        if case .notFound = result {
            // Success
        } else {
            Issue.record("Expected notFound for empty directory, got \(result)")
        }

		#expect(throws: GeneratorError.self) {
			try ConfigDiscovery.resolvedConfigURL(nil, fileManager: manager)
		}
    }

	@Test func `Search in directory, single config found`() throws {
		let tempDir = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: tempDir) }

		let configFile = tempDir.appending(path: "buildsettings.yaml")
		try "settings: []".write(to: configFile, atomically: true, encoding: .utf8)

		let manager = FileManager()
		manager.changeCurrentDirectoryPath(tempDir.path())

		let result = ConfigDiscovery.search(from: tempDir, fileManager: manager)
		if case let .found(url) = result {
			#expect(url.lastPathComponent == "buildsettings.yaml")
		} else {
			Issue.record("Expected found(url), got \(result)")
		}

		let resolved = try ConfigDiscovery.resolvedConfigURL(nil, fileManager: manager)
		#expect(resolved.standardizedFileURL.path() == configFile.standardizedFileURL.path())
	}

	@Test func `Search in directory, multiple configs found`() throws {
		let tempDir = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: tempDir) }

		let configFile = tempDir.appending(path: "buildsettings.yaml")
		try "settings: []".write(to: configFile, atomically: true, encoding: .utf8)
		
		let secondConfigFile = tempDir.appending(path: ".buildsettings.yml")
		try "settings: []".write(to: secondConfigFile, atomically: true, encoding: .utf8)

		let manager = FileManager()
		manager.changeCurrentDirectoryPath(tempDir.path())

		let result = ConfigDiscovery.search(from: tempDir, fileManager: manager)
		if case let .ambiguous(candidates) = result {
			#expect(candidates.count == 2)
		} else {
			Issue.record("Expected ambiguous, got \(result)")
		}

		#expect(throws: GeneratorError.self) {
			try ConfigDiscovery.resolvedConfigURL(nil, fileManager: manager)
		}
	}

    @Test func `custom config file provided is returned`() throws {
		let tempDir = try TempDir.create()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let file = tempDir.appending(path: "custom.yaml")
        try "settings: []".write(to: file, atomically: true, encoding: .utf8)

        let resolved = try ConfigDiscovery.resolvedConfigURL(file)
		#expect(resolved == file)
    }
}

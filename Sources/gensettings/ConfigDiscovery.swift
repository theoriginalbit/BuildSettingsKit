//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL
import protocol Foundation.LocalizedError
import class Foundation.FileManager

enum ConfigDiscoveryError: Error, LocalizedError {
	/// No config files found.
	case notFound

	/// More than 1 config file found.
	case multipleFound(files: [URL])

	var errorDescription: String? {
		switch self {
		case .notFound:
			return "No config file found. Provide --config argument or add a config file to the current working directory."
		case let .multipleFound(candidates):
			let list = candidates
				.map { "  - \($0)" }
				.joined(separator: "\n")
			return """
				Multiple config files found, but exactly one is expected.
				Use --config to specify which one to use:
				\(list)
				"""
		}
	}
}

enum ConfigDiscovery {
	static let supportedConfigFiles: Set<String> = [
		"buildsettings.yaml",
		"buildsettings.yml",
		".buildsettings.yaml",
		".buildsettings.yml",
	]

	static func locateConfig(in inputFiles: [URL], fallbackSearchDirectory: URL, fileManager: FileManager = .default) throws(ConfigDiscoveryError) -> URL {
		do {
			return try Self.locateConfig(in: inputFiles)
		} catch ConfigDiscoveryError.notFound {
			// then try to find a config in the fallback dir
			let files = try? fileManager.contentsOfDirectory(
				at: fallbackSearchDirectory,
				includingPropertiesForKeys: [.isDirectoryKey]
			)
			if let files {
				return try Self.locateConfig(in: files)
			}
			throw .notFound
		}
	}

	/// Find the config file.
	static func locateConfig(in inputFiles: [URL]) throws(ConfigDiscoveryError) -> URL {
		let matchedConfigs = inputFiles.filter(isSupportedConfigFileName(_:))
		guard matchedConfigs.count > 0 else {
			throw .notFound
		}
		guard matchedConfigs.count == 1 else {
			throw .multipleFound(files: matchedConfigs)
		}
		return matchedConfigs[0]
	}

	private static func isSupportedConfigFileName(_ url: URL) -> Bool {
		let fileName = url.lastPathComponent
		for acceptedFileName in supportedConfigFiles where fileName.caseInsensitiveCompare(acceptedFileName) == .orderedSame {
			return true
		}
		return false
	}
}

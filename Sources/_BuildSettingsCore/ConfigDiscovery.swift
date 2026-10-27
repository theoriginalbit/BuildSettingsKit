//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation

package enum ConfigDiscoveryResult {
	case found(URL)
	case ambiguous([URL])
	case notFound
}

package enum ConfigDiscovery {
	static let acceptedFileNames: [String] = [
		"buildsettings.yaml",
		"buildsettings.yml",
		".buildsettings.yaml",
		".buildsettings.yml",
	]

	static func directConfigs(in directory: URL, fileManager: FileManager) -> [URL] {
		guard let entries = try? fileManager.contentsOfDirectory(
			at: directory,
			includingPropertiesForKeys: [.isDirectoryKey],
			options: []
		) else { return [] }

		var candidates: [URL] = []
		for entry in entries where isAcceptedFileName(entry) {
			candidates.append(entry)
		}
		return candidates
	}

	static func isAcceptedFileName(_ url: URL) -> Bool {
		let fileName = url.lastPathComponent
		for acceptedFileName in acceptedFileNames where fileName.caseInsensitiveCompare(acceptedFileName) == .orderedSame {
			return true
		}
		return false
	}
}

package extension ConfigDiscovery {
	static func resolvedConfigURL(_ config: URL?) throws(GeneratorError) -> URL {
		let fileManager = FileManager.default

		// Invocation provided.
		if let config {
			guard config.isFileURL, fileManager.fileExists(atPath: config.path()) else {
				throw .missingConfigFile(path: config.path())
			}
			return config
		}

		// Auto-discover.
		let cwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
		switch ConfigDiscovery.search(from: cwd, fileManager: fileManager) {
		case let .found(url):
			return url
		case let .ambiguous(candidates):
			throw .ambiguousConfig(candidates: candidates.map(\.path))
		case .notFound:
			throw .noConfigFound(searchRoot: cwd.path)
		}
	}

	static func search(from currentDirectory: URL, fileManager: FileManager) -> ConfigDiscoveryResult {
		let candidates = directConfigs(in: currentDirectory.standardizedFileURL, fileManager: fileManager)
		return if candidates.isEmpty {
			.notFound
		} else if candidates.count == 1 {
			.found(candidates[0])
		} else {
			.ambiguous(candidates)
		}
	}
}

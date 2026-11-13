//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL
import PackagePlugin

@main struct BuildSettingsKitPlugin {
	func createBuildCommands(
		rootDirectory: URL,
		pluginWorkDirectory: URL,
		tool: (String) throws -> PluginContext.Tool,
		sourceFiles: FileList,
		targetName: String,
	) throws -> [Command] {
		do {
			let tool = try tool("gensettings")
			let configURL = try ConfigDiscovery.locateConfig(in: sourceFiles.map(\.url), fallbackSearchDirectory: rootDirectory)
			let outputFile = pluginWorkDirectory.appending(component: Constants.outputFileName)
			let arguments = [
				"generate", "--build-tool", "--xcode",
				"--config", configURL.path(percentEncoded: false),
				"--output", outputFile.path(percentEncoded: false),
			]

			return [
				.buildCommand(
					displayName: "Running gensettings",
					executable: tool.url,
					arguments: arguments,
					inputFiles: [
						configURL,
					],
					outputFiles: [
						outputFile,
					],
				)
			]
		} catch let error as ConfigDiscoveryError {
			throw mapToPluginError(error, target: targetName)
		}
	}

	func mapToPluginError(_ error: ConfigDiscoveryError, target: String) -> PluginError {
		switch error {
		case .notFound:
			.configNotFound(targetName: target)
		case let .multipleFound(files):
			.multipleConfigsFound(files: files, targetName: target)
		}
	}
}

extension BuildSettingsKitPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: any Target) async throws -> [Command] {
		guard let swiftTarget = target as? SwiftSourceModuleTarget else {
			throw PluginError.incompatibleTarget(name: target.name)
		}
		return try createBuildCommands(
			rootDirectory: context.package.directoryURL,
			pluginWorkDirectory: context.pluginWorkDirectoryURL,
			tool: context.tool,
			sourceFiles: swiftTarget.sourceFiles,
			targetName: target.name,
		)
	}
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension BuildSettingsKitPlugin: XcodeBuildToolPlugin {
	func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
		try createBuildCommands(
			rootDirectory: context.xcodeProject.directoryURL,
			pluginWorkDirectory: context.pluginWorkDirectoryURL,
			tool: context.tool,
			sourceFiles: target.inputFiles,
			targetName: target.displayName,
		)
	}
}
#endif

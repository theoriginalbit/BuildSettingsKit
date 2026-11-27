// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "BuildSettingsKit",
	platforms: [
		.macOS(.v15),

		// Declared so it can be a plugin on a project of the following
		.iOS(.v18), .watchOS(.v11), .tvOS(.v18), .visionOS(.v2),
	],
	products: [
		.executable(
			name: "gensettings",
			targets: ["gensettings"],
		),
		.plugin(
			name: "BuildSettingsKitPlugin",
			targets: ["BuildSettingsKitPlugin"],
		),
	],
	dependencies: [
		.package(url: "https://github.com/jpsim/Yams", .upToNextMinor(from: "6.2.2")),
		.package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.8.2")),
		.package(url: "https://github.com/theoriginalbit/SwiftStructureKit", .upToNextMajor(from: "4.1.0")),
	],
	targets: [
		.target(
			name: "_BuildSettingsCore",
			dependencies: [
				.product(name: "Yams", package: "Yams"),
				.product(name: "SwiftStructureKit", package: "SwiftStructureKit"),
			],
		),
		.executableTarget(
			name: "gensettings",
			dependencies: [
				.target(name: "_BuildSettingsCore"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
		),
		.testTarget(
			name: "_BuildSettingsCoreTests",
			dependencies: [
				.target(name: "_BuildSettingsCore"),
				.product(name: "SwiftStructureKitTestSupport", package: "SwiftStructureKit"),
			],
			resources: [
				.copy("Resources"),
			],
		),
		.testTarget(
			name: "BuildSettingsKitTests",
			dependencies: [
				.target(name: "gensettings"),
			],
		),
		.plugin(
			name: "BuildSettingsKitPlugin",
			capability: .buildTool(),
			dependencies: [
				.target(name: "gensettings"),
			],
		),
	],
)

for target in package.targets where target.type != .plugin {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: [
		.swiftLanguageMode(.v6),
		.enableUpcomingFeature("MemberImportVisibility"),
		.enableUpcomingFeature("ApproachableConcurrency"),
	])
	target.swiftSettings = settings
}

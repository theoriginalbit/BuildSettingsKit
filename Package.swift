// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "BuildSettingsKit",
	platforms: [
		.macOS(.v15),
	],
	products: [
		.executable(
			name: "gensettings",
			targets: ["BuildSettingsKit"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/jpsim/Yams", .upToNextMinor(from: "6.2.2")),
		.package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.8.2")),
	],
	targets: [
		.target(
			name: "_BuildSettingsCore",
			dependencies: [
				.product(name: "Yams", package: "Yams"),
			]
		),
		.executableTarget(
			name: "BuildSettingsKit",
			dependencies: [
				.target(name: "_BuildSettingsCore"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
		),
		.testTarget(
			name: "BuildSettingsKitTests",
			dependencies: [
				.target(name: "BuildSettingsKit"),
			],
		),
	]
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

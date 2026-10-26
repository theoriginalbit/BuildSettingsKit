// swift-tools-version: 6.4

import PackageDescription

let package = Package(
	name: "BuildSettingsKit",
	platforms: [
		.macOS(.v15),
	],
    products: [
        .library(
            name: "BuildSettingsKit",
            targets: ["BuildSettingsKit"]
        ),
    ],
    targets: [
        .target(name: "BuildSettingsKit"),
        .testTarget(
            name: "BuildSettingsKitTests",
            dependencies: ["BuildSettingsKit"],
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

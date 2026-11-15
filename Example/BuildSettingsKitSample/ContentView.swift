import SwiftUI

struct ContentView: View {
	var version: String {
		"Version \(BuildConfig.marketingVersion) (\(BuildConfig.buildNumber))"
	}

	var body: some View {
		NavigationStack {
			List {
				Section("Arrays") {
					ForEach(BuildConfig.supportedPlatforms, id: \.self) { item in
						Text(item)
					}
				}
			}

			HStack(spacing: 16) {
				Text(version)
				Text("API Server: " + BuildConfig.apiBaseUrl.absoluteString)
			}
			.padding()
			.font(.caption)
			.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	ContentView()
}

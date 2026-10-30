//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.Data
import class Yams.YAMLDecoder

package enum ConfigLoader {
	package static func load(from configURL: URL) throws(GeneratorError) -> Configuration {
		do {
			let data = try Data(contentsOf: configURL)
			let contents = String(decoding: data, as: UTF8.self)
			if data.isEmpty || contents.allSatisfy(\.isWhitespace) {
				throw GeneratorError.emptyConfigFile(configURL)
			}
			return try YAMLDecoder().decode(Configuration.self, from: contents)
		} catch let error as GeneratorError {
			throw error
		} catch let error as DecodingError {
			throw GeneratorError.invalidConfigFile(configURL, error: error)
		} catch {
			throw GeneratorError.invalidConfigFile(configURL, error: error)
		}
	}
}

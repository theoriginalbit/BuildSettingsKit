//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation
import Testing
@testable import _BuildSettingsCore

final class TestOutputHandle: DiagnosticOutputHandle, @unchecked Sendable {
    private var _output = ""

    var output: String {
        return _output
    }

    func write(_ data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            _output += string
        }
    }
}

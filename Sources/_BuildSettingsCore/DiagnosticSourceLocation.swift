//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

/// A source position within a file. Indexes start at `1`.
///
/// Used to attach YAML source positions to setting entries so that
/// diagnostics can point at the exact line in `.buildsettings.yaml`.
package struct DiagnosticSourceLocation: CustomStringConvertible {
	/// The line within the file. Indexes start at `1`.
	package let line: Int

	/// The column within the file. Indexes start at `1`.
	package let column: Int

	package var description: String {
		"L\(line):\(column)"
	}
}

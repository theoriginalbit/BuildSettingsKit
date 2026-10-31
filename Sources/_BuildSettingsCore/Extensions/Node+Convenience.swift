//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Yams

extension Node {
	/// Walks the coding path down the tree to get the node.
	func node(at path: [CodingKey]) -> Node? {
		var currentNode = self
		for key in path {
			if let indexKey = key.intValue, let node = currentNode.sequence?[indexKey] {
				currentNode = node
			} else if let node = currentNode.mapping?[key.stringValue] {
				currentNode = node
			} else {
				// could not locate node for key, exit
				return nil
			}
		}
		return currentNode
	}

	func nearestNode(at path: [CodingKey]) -> Node {
		var p = path
		while !p.isEmpty {
			if let n = node(at: p) { return n }
			p.removeLast()
		}
		return self
	}
}

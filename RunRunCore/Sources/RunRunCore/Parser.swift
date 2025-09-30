import Foundation

public enum ParseError: Error, Equatable {
	case emptyInput
	case unexpectedToken(String)
	case invalidRepeat(String)
	case invalidLabel(String)
	case unclosedGroup
	case repeatWithoutTarget
}

public struct ProgramParser {
	public init() {}
	
	public func parse(_ input: String) throws -> Workout {
		guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ParseError.emptyInput
		}
		
		let tokens = try tokenize(input)
		let (parsed, _) = try parseExpression(tokens, 0)
		let segments = expandWorkout(parsed)
		
		let totals = WorkoutTotals(segments: segments)
		
		return Workout(
			original: input,
			segments: segments,
			totals: totals
		)
	}
	
	public func parseWithAST(_ input: String) throws -> (workout: Workout, ast: String) {
		guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ParseError.emptyInput
		}
		
		let tokens = try tokenize(input)
		let (parsed, _) = try parseExpression(tokens, 0)
		let segments = expandWorkout(parsed)
		
		let totals = WorkoutTotals(segments: segments)
		
		let workout = Workout(
			original: input,
			segments: segments,
			totals: totals
		)
		
		let astString = formatAST(parsed)
		
		return (workout: workout, ast: astString)
	}
	
	// Tokenize function matching JavaScript implementation
	private func tokenize(_ input: String) throws -> [Token] {
		var tokens: [Token] = []
		var index = input.startIndex
		
		while index < input.endIndex {
			let char = input[index]
			
			// Skip whitespace
			if char.isWhitespace {
				index = input.index(after: index)
				continue
			}
			
			// Handle parentheses
			if char == "(" {
				tokens.append(.lparen)
				index = input.index(after: index)
				continue
			}
			
			if char == ")" {
				tokens.append(.rparen)
				index = input.index(after: index)
				continue
			}
			
			// Handle @ labels
			if char == "@" {
				var label = ""
				index = input.index(after: index)
				while index < input.endIndex && (input[index].isLetter || input[index].isNumber || input[index] == "_" || input[index] == "." || input[index] == "-") {
					label.append(input[index])
					index = input.index(after: index)
				}
				tokens.append(.label(label))
				continue
			}
			
			// Handle x repeats
			if char.lowercased() == "x" {
				index = input.index(after: index)
				var countStr = ""
				while index < input.endIndex && input[index].isNumber {
					countStr.append(input[index])
					index = input.index(after: index)
				}
				guard let count = Int(countStr), count > 0 else {
					throw ParseError.invalidRepeat("x\(countStr)")
				}
				tokens.append(.`repeat`(count))
				continue
			}
			
			// Handle PWR segments
			if char.lowercased() == "p" || char.lowercased() == "w" || char.lowercased() == "r" {
				let typeChar = char
				index = input.index(after: index)
				
				var valueStr = ""
				var hasAt = false
				var label = ""
				
				// Read the value part
				while index < input.endIndex && !input[index].isWhitespace && input[index] != "(" && input[index] != ")" {
					if input[index] == "@" {
						hasAt = true
						index = input.index(after: index)
			break
		}
					valueStr.append(input[index])
					index = input.index(after: index)
				}
				
				// Read label if we found @
				if hasAt {
					while index < input.endIndex && !input[index].isWhitespace && input[index] != "(" && input[index] != ")" {
						label.append(input[index])
						index = input.index(after: index)
					}
				}
				
				let type = segmentType(from: typeChar)
				let seconds = try parseDuration(valueStr)
				
				if hasAt {
					tokens.append(.segment(type, seconds, label))
				} else {
					tokens.append(.segment(type, seconds, nil))
				}
				continue
			}
			
			// Unknown character
			throw ParseError.unexpectedToken(String(char))
		}
		
		return tokens
	}
	
	private func segmentType(from char: Character) -> SegmentType {
		switch char.lowercased() {
		case "p": return .prepare
		case "w": return .work
		case "r": return .rest
		default: return .work
		}
	}
	
	private func parseDuration(_ str: String) throws -> Int {
		if str.isEmpty || str == "0" { return 0 }
		
		// Handle plain seconds
		if str.allSatisfy({ $0.isNumber }) {
			return Int(str) ?? 0
		}
		
		// Handle time units like 2m, 1h30m, etc.
		var total = 0
		let regex = try NSRegularExpression(pattern: "(\\d+)([hms]?)")
		let range = NSRange(str.startIndex..., in: str)
		let matches = regex.matches(in: str, range: range)
		
		for match in matches {
			guard match.numberOfRanges >= 3 else { continue }
			let valueRange = match.range(at: 1)
			let unitRange = match.range(at: 2)
			
			guard valueRange.location != NSNotFound,
				  let value = Int(String(str[Range(valueRange, in: str)!])) else { continue }
			
			let unit = unitRange.location != NSNotFound ? String(str[Range(unitRange, in: str)!]) : "s"
			
			switch unit {
			case "h": total += value * 3600
			case "m": total += value * 60
			case "s", "": total += value
			default: total += value
			}
		}
		
		return total
	}
	
	// Parse expression matching JavaScript implementation
	private func parseExpression(_ tokens: [Token], _ pos: Int) throws -> (ASTNode, Int) {
		var items: [ASTNode] = []
		var pos = pos
		
		while pos < tokens.count && tokens[pos] != .rparen {
			if tokens[pos] == .lparen {
				let (group, newPos) = try parseGroup(tokens, pos)
				items.append(group)
				pos = newPos
			} else if case .`repeat`(let count) = tokens[pos] {
				pos += 1
				let target: ASTNode
				if !items.isEmpty {
					// Postfix form: target is the previous item
					target = items.removeLast()
				} else {
					// Prefix form: target is the next item or group
					if pos < tokens.count && tokens[pos] == .lparen {
						let (group, newPos) = try parseGroup(tokens, pos)
						target = group
						pos = newPos
					} else if pos < tokens.count && tokens[pos] != .rparen {
						// Parse a sequence of segments until we hit a repeat or end
						var segmentItems: [ASTNode] = []
						while pos < tokens.count && tokens[pos] != .rparen && tokens[pos] != .lparen {
							if case .`repeat`(_) = tokens[pos] {
								break
							}
							let (segment, newPos) = try parseSegment(tokens, pos)
							segmentItems.append(segment)
							pos = newPos
						}
						if segmentItems.count == 1 {
							target = segmentItems[0]
						} else if segmentItems.isEmpty {
							// If no segments found, try to parse the next token as a group or segment
							if pos < tokens.count && tokens[pos] == .lparen {
								let (group, newPos) = try parseGroup(tokens, pos)
								target = group
								pos = newPos
							} else if pos < tokens.count {
								let (segment, newPos) = try parseSegment(tokens, pos)
								target = segment
								pos = newPos
							} else {
								throw ParseError.repeatWithoutTarget
							}
						} else {
							target = .sequence(segmentItems)
						}
					} else {
						throw ParseError.repeatWithoutTarget
					}
				}
				items.append(.`repeat`(count, target))
			} else if case .label(let label) = tokens[pos] {
				pos += 1
				guard !items.isEmpty else {
					throw ParseError.unexpectedToken("@\(label)")
				}
				let target = items.removeLast()
				items.append(attachLabel(target, label))
			} else {
				let (segment, newPos) = try parseSegment(tokens, pos)
				items.append(segment)
				pos = newPos
			}
		}
		
		return (.sequence(items), pos)
	}
	
	private func parseGroup(_ tokens: [Token], _ pos: Int) throws -> (ASTNode, Int) {
		var pos = pos + 1 // skip '('
		let (content, newPos) = try parseExpression(tokens, pos)
		pos = newPos
		guard pos < tokens.count && tokens[pos] == .rparen else {
			throw ParseError.unclosedGroup
		}
		pos += 1 // skip ')'
		
		// If the group starts with a prefix repeat like: (x3 A B),
		// we want the repeat to target the entire remainder sequence (A B),
		// not only the immediate next item. Fold subsequent items into the repeat target.
		if case .sequence(let items) = content, items.count >= 2 {
			let first = items[0]
			if case .`repeat`(let count, let firstTarget) = first {
				let tail = Array(items.dropFirst())
				let mergedTarget: ASTNode
				switch firstTarget {
				case .sequence(let inner):
					mergedTarget = .sequence(inner + tail)
				default:
					mergedTarget = .sequence([firstTarget] + tail)
				}
				return (.sequence([ .`repeat`(count, mergedTarget) ]), pos)
			}
		}
		
		return (content, pos)
	}
	
	private func parseSegment(_ tokens: [Token], _ pos: Int) throws -> (ASTNode, Int) {
		guard pos < tokens.count else {
			throw ParseError.unexpectedToken("EOF")
		}
		
		switch tokens[pos] {
		case .segment(let type, let seconds, let label):
			return (.segment(type, seconds, label), pos + 1)
		default:
			throw ParseError.unexpectedToken("Expected segment")
		}
	}
	
	private func attachLabel(_ node: ASTNode, _ label: String) -> ASTNode {
		switch node {
		case .segment(let type, let seconds, _):
			return .segment(type, seconds, label)
		case .sequence(let items):
			return .sequence(items.map { attachLabel($0, label) })
		case .`repeat`(let count, let target):
			return .`repeat`(count, attachLabel(target, label))
		}
	}
}

// Token types matching JavaScript implementation
private enum Token: Equatable {
	case segment(SegmentType, Int, String?) // type, seconds, label
	case `repeat`(Int) // count
	case lparen
	case rparen
	case label(String) // @label
}

// AST Node types matching JavaScript implementation
private indirect enum ASTNode {
	case segment(SegmentType, Int, String?) // type, seconds, label
	case sequence([ASTNode]) // items
	case `repeat`(Int, ASTNode) // count, target
}

// Expansion engine matching JavaScript implementation
private func expandWorkout(_ parsed: ASTNode, label: String? = nil) -> [Segment] {
		var segments: [Segment] = []
	
	func expand(_ node: ASTNode, inheritedLabel: String?) {
		let currentLabel = getLabel(node) ?? inheritedLabel
		
			switch node {
		case .segment(let type, let seconds, _):
			segments.append(Segment(
				index: segments.count,
				type: type,
				seconds: seconds,
				label: currentLabel
			))
		case .sequence(let items):
			items.forEach { expand($0, inheritedLabel: currentLabel) }
		case .`repeat`(let count, let target):
			// Special handling for repeated groups that end with rest
			if case .sequence(let groupItems) = target, 
			   let lastItem = groupItems.last,
			   case .segment(let lastType, _, _) = lastItem,
			   lastType == .rest {
				// For repeated groups ending with rest, repeat the full group but remove last rest from the last repetition
				for i in 0..<count {
					for (j, item) in groupItems.enumerated() {
						// Skip the last rest segment only in the last repetition
						if i == count - 1 && j == groupItems.count - 1 {
							continue
						}
						expand(item, inheritedLabel: currentLabel)
					}
				}
			} else {
				// Normal repetition
				for _ in 0..<count {
					expand(target, inheritedLabel: currentLabel)
				}
			}
		}
	}
	
	expand(parsed, inheritedLabel: label)
	
	// Apply rule: If workout ends with rest, remove the last rest segment
	// This matches the JavaScript implementation behavior, but only for certain cases
	// Don't remove rest if it's the only segment or if it has a specific label
	if segments.count > 1, 
	   let lastSegment = segments.last, 
	   lastSegment.type == .rest,
	   lastSegment.label != "rest" {
		segments.removeLast()
	}
	
	// Assign correct indices
	for (i, segment) in segments.enumerated() {
		segments[i] = Segment(
			index: i,
			type: segment.type,
			seconds: segment.seconds,
			label: segment.label
		)
	}
	
	return segments
}

private func getLabel(_ node: ASTNode) -> String? {
	switch node {
	case .segment(_, _, let label):
		return label
	case .sequence, .`repeat`:
		return nil
	}
}

private func formatAST(_ node: ASTNode) -> String {
	switch node {
	case .segment(let type, let seconds, let label):
		let labelStr = label.map { "@\($0)" } ?? ""
		return "\(type)\(seconds)\(labelStr)"
	case .sequence(let items):
		let itemsStr = items.map { formatAST($0) }.joined(separator: " ")
		return "(\(itemsStr))"
	case .`repeat`(let count, let target):
		return "x\(count) \(formatAST(target))"
	}
}
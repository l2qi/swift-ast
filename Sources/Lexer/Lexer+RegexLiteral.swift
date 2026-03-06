/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

extension Lexer /* regex literal */ {
  func lexRegexLiteral(hashCount: Int) -> Token.Kind {
    let delimiter = String(repeating: "#", count: hashCount)
    var pattern = ""
    var rawRepresentation = delimiter + "/"

    // Detect multiline: opening / immediately followed by newline
    let isMultiline: Bool
    if char.unicodeScalar == "\n" {
      isMultiline = true
      rawRepresentation += "\n"
      _consume(char.role)
    } else if char.unicodeScalar == "\r" {
      isMultiline = true
      rawRepresentation += "\r"
      _consume(char.role)
      if char.unicodeScalar == "\n" {  // \r\n
        rawRepresentation += "\n"
        _consume(char.role)
      }
    } else {
      isMultiline = false
    }

    // Track content on current line (for multiline closing detection)
    var currentLineContent = ""

    while char != .eof {
      // Check for closing delimiter: / followed by hashCount #s
      if char.unicodeScalar == "/" {
        var matched = true
        for i in 0..<hashCount {
          if _scanner.peek(ahead: i) != "#" {
            matched = false
            break
          }
        }
        if matched {
          if !isMultiline {
            // Single-line: always close
            rawRepresentation += "/" + delimiter
            _consume(nil, andAdvanceScannerBy: 1 + hashCount)
            return .regexLiteral(pattern, rawRepresentation: rawRepresentation)
          } else if currentLineContent.allSatisfy({ $0 == " " || $0 == "\t" }) {
            // Multiline: close only if / is preceded only by whitespace on this line
            let whitespaceLen = currentLineContent.count
            if whitespaceLen > 0 {
              pattern.removeLast(whitespaceLen)
            }
            // Strip trailing newline from pattern
            if pattern.hasSuffix("\r\n") {
              pattern.removeLast(2)
            } else if pattern.hasSuffix("\n") || pattern.hasSuffix("\r") {
              pattern.removeLast()
            }
            rawRepresentation += "/" + delimiter
            _consume(nil, andAdvanceScannerBy: 1 + hashCount)
            return .regexLiteral(pattern, rawRepresentation: rawRepresentation)
          }
        }
      }

      // Newline handling
      if char.unicodeScalar == "\n" || char.unicodeScalar == "\r" {
        if !isMultiline {
          return .invalid(.unterminatedRegexLiteral)
        }
        currentLineContent = ""
      } else {
        currentLineContent += char.string
      }

      rawRepresentation += char.string
      pattern += char.string
      _consume(char.role)
    }
    return .invalid(.unterminatedRegexLiteral)
  }
}

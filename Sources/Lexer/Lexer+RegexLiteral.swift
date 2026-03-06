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
  func lexRegexLiteral() -> Token.Kind {
    var pattern = ""
    var rawRepresentation = "#/"

    while char != .eof {
      if char.unicodeScalar == "/" && _scanner.peek() == "#" {
        rawRepresentation += "/#"
        _consume(nil, andAdvanceScannerBy: 2)  // consume /#
        return .regexLiteral(pattern, rawRepresentation: rawRepresentation)
      }
      if char.unicodeScalar == "\n" || char.unicodeScalar == "\r" {
        return .invalid(.unterminatedRegexLiteral)
      }
      rawRepresentation += char.string
      pattern += char.string
      _consume(char.role)
    }
    return .invalid(.unterminatedRegexLiteral)
  }
}

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

import XCTest

@testable import AST

class ParserMacroDeclarationTests: XCTestCase {
  func testMacroWithDefinition() {
    parseDeclarationAndTest(
      "macro stringify(_: Any) -> (String, Any) = #externalMacro(module: \"M\", type: \"T\")",
      "macro stringify(_: Any) -> (String, Any) = #externalMacro(module: \"M\", type: \"T\")",
      testClosure: { decl in
      guard let macroDecl = decl as? MacroDeclaration else {
        XCTFail("Failed in getting a macro declaration")
        return
      }
      XCTAssertTrue(macroDecl.attributes.isEmpty)
      XCTAssertNil(macroDecl.accessLevelModifier)
      ASTTextEqual(macroDecl.name, "stringify")
      XCTAssertNil(macroDecl.genericParameterClause)
      XCTAssertEqual(macroDecl.signature.parameterList.count, 1)
      XCTAssertNotNil(macroDecl.signature.result)
      XCTAssertNil(macroDecl.genericWhereClause)
      XCTAssertNotNil(macroDecl.definition)
    })
  }

  func testPublicMacro() {
    parseDeclarationAndTest(
      "public macro myMacro()",
      "public macro myMacro()",
      testClosure: { decl in
      guard let macroDecl = decl as? MacroDeclaration else {
        XCTFail("Failed in getting a macro declaration")
        return
      }
      XCTAssertTrue(macroDecl.attributes.isEmpty)
      XCTAssertNotNil(macroDecl.accessLevelModifier)
      ASTTextEqual(macroDecl.name, "myMacro")
      XCTAssertEqual(macroDecl.signature.parameterList.count, 0)
      XCTAssertNil(macroDecl.signature.result)
      XCTAssertNil(macroDecl.definition)
    })
  }

  func testMacroWithGenerics() {
    parseDeclarationAndTest(
      "macro withGenerics<T>(value: T) -> T",
      "macro withGenerics<T>(value: T) -> T",
      testClosure: { decl in
      guard let macroDecl = decl as? MacroDeclaration else {
        XCTFail("Failed in getting a macro declaration")
        return
      }
      ASTTextEqual(macroDecl.name, "withGenerics")
      XCTAssertNotNil(macroDecl.genericParameterClause)
      XCTAssertEqual(macroDecl.signature.parameterList.count, 1)
      XCTAssertNotNil(macroDecl.signature.result)
      XCTAssertNil(macroDecl.definition)
    })
  }

  func testMacroWithAttributes() {
    parseDeclarationAndTest(
      "@attached(member) macro MyMacro() = #externalMacro(module: \"M\", type: \"T\")",
      "@attached(member) macro MyMacro() = #externalMacro(module: \"M\", type: \"T\")",
      testClosure: { decl in
      guard let macroDecl = decl as? MacroDeclaration else {
        XCTFail("Failed in getting a macro declaration")
        return
      }
      XCTAssertFalse(macroDecl.attributes.isEmpty)
      XCTAssertNil(macroDecl.accessLevelModifier)
      ASTTextEqual(macroDecl.name, "MyMacro")
      XCTAssertEqual(macroDecl.signature.parameterList.count, 0)
      XCTAssertNil(macroDecl.signature.result)
      XCTAssertNotNil(macroDecl.definition)
    })
  }

  static let allTests = [
    ("testMacroWithDefinition", testMacroWithDefinition),
    ("testPublicMacro", testPublicMacro),
    ("testMacroWithGenerics", testMacroWithGenerics),
    ("testMacroWithAttributes", testMacroWithAttributes),
  ]
}

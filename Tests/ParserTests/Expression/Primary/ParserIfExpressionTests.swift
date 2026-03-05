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

class ParserIfExpressionTests: XCTestCase {
  func testBasicIfExpression() {
    parseExpressionAndTest(
      "if true { 1 } else { 2 }",
      "if true {\n1\n} else {\n2\n}",
      testClosure: { expr in
      guard let ifExpr = expr as? IfExpression else {
        XCTFail("Failed in getting an if expression")
        return
      }
      XCTAssertEqual(ifExpr.conditionList.count, 1)
      guard case .else = ifExpr.elseClause else {
        XCTFail("Expected else clause")
        return
      }
    })
  }

  func testChainedElseIfExpression() {
    parseExpressionAndTest(
      "if a { 1 } else if b { 2 } else { 3 }",
      "if a {\n1\n} else if b {\n2\n} else {\n3\n}",
      testClosure: { expr in
      guard let ifExpr = expr as? IfExpression else {
        XCTFail("Failed in getting an if expression")
        return
      }
      XCTAssertEqual(ifExpr.conditionList.count, 1)
      guard case .elseif(let elseIfExpr) = ifExpr.elseClause else {
        XCTFail("Expected elseif clause")
        return
      }
      XCTAssertEqual(elseIfExpr.conditionList.count, 1)
      guard case .else = elseIfExpr.elseClause else {
        XCTFail("Expected else clause in nested if")
        return
      }
    })
  }

  func testIfExpressionEmptyBodies() {
    parseExpressionAndTest(
      "if foo {} else {}",
      "if foo {} else {}",
      testClosure: { expr in
      guard let ifExpr = expr as? IfExpression else {
        XCTFail("Failed in getting an if expression")
        return
      }
      XCTAssertEqual(ifExpr.conditionList.count, 1)
    })
  }

  func testSourceRange() {
    parseExpressionAndTest(
      "if foo {} else {}",
      "if foo {} else {}",
      testClosure: { expr in
      guard let ifExpr = expr as? IfExpression else {
        XCTFail("Failed in getting an if expression")
        return
      }
      XCTAssertEqual(ifExpr.sourceRange, getRange(1, 1, 1, 18))
    })
  }

  static let allTests = [
    ("testBasicIfExpression", testBasicIfExpression),
    ("testChainedElseIfExpression", testChainedElseIfExpression),
    ("testIfExpressionEmptyBodies", testIfExpressionEmptyBodies),
    ("testSourceRange", testSourceRange),
  ]
}

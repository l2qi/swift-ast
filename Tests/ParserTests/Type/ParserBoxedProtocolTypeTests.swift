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

class ParserBoxedProtocolTypeTests: XCTestCase {
  func testBoxedProtocolType() {
    parseTypeAndTest("any Thing", "any Thing", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolTypeWithDotSeparatedName() {
    parseTypeAndTest("any Foo.Bar", "any Foo.Bar", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolTypeWithGenerics() {
    parseTypeAndTest("any Collection<Int>", "any Collection<Int>", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }
}

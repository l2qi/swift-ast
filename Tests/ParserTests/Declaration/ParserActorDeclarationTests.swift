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
@testable import Parser

class ParserActorDeclarationTests: XCTestCase {
  func testEmptyActor() {
    parseDeclarationAndTest("actor MyActor {}", "actor MyActor {}", testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertTrue(actorDecl.attributes.isEmpty)
      XCTAssertNil(actorDecl.accessLevelModifier)
      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
      XCTAssertNil(actorDecl.genericParameterClause)
      XCTAssertNil(actorDecl.typeInheritanceClause)
      XCTAssertNil(actorDecl.genericWhereClause)
      XCTAssertTrue(actorDecl.members.isEmpty)
    })
  }

  func testActorWithAccessLevel() {
    parseDeclarationAndTest("public actor MyActor {}", "public actor MyActor {}", testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.accessLevelModifier, .public)
      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
    })
  }

  func testActorWithInheritance() {
    parseDeclarationAndTest(
      "actor MyActor: SomeProtocol {}",
      "actor MyActor: SomeProtocol {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "MyActor")
      XCTAssertNotNil(actorDecl.typeInheritanceClause)
    })
  }

  func testActorWithMembers() {
    parseDeclarationAndTest(
      "actor Counter { var count = 0; func increment() { count += 1 } }",
      """
      actor Counter {
      var count = 0
      func increment() {
      count += 1
      }
      }
      """,
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "Counter")
      XCTAssertEqual(actorDecl.members.count, 2)
    })
  }

  func testActorWithGenericParameter() {
    parseDeclarationAndTest(
      "actor Box<T> {}",
      "actor Box<T> {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.name.textDescription, "Box")
      XCTAssertNotNil(actorDecl.genericParameterClause)
    })
  }

  func testActorWithGenericWhereClause() {
    parseDeclarationAndTest(
      "actor MyActor<T> where T: Sendable {}",
      "actor MyActor<T> where T: Sendable {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertNotNil(actorDecl.genericParameterClause)
      XCTAssertNotNil(actorDecl.genericWhereClause)
    })
  }

  func testActorWithAttribute() {
    parseDeclarationAndTest(
      "@globalActor actor MyGlobalActor {}",
      "@globalActor actor MyGlobalActor {}",
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertFalse(actorDecl.attributes.isEmpty)
      XCTAssertEqual(actorDecl.name.textDescription, "MyGlobalActor")
    })
  }

  func testActorWithNonisolatedMember() {
    parseDeclarationAndTest(
      "actor MyActor { nonisolated func getId() -> String { id } }",
      """
      actor MyActor {
      nonisolated func getId() -> String {
      id
      }
      }
      """,
      testClosure: { decl in
      guard let actorDecl = decl as? ActorDeclaration else {
        XCTFail("Failed in getting an actor declaration.")
        return
      }

      XCTAssertEqual(actorDecl.members.count, 1)
      if case .declaration(let memberDecl) = actorDecl.members[0],
         let funcDecl = memberDecl as? FunctionDeclaration {
        XCTAssertEqual(funcDecl.modifiers.count, 1)
        XCTAssertEqual(funcDecl.modifiers[0], .nonisolated)
      } else {
        XCTFail("Expected a function declaration member.")
      }
    })
  }
}

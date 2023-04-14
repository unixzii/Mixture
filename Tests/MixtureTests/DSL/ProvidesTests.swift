/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

fileprivate struct MyComponentGraph: ComponentGraph {
    var body: some ComponentGraph {
        Provides { () -> BasicTypeA in
            return .init()
        }
        ComponentGraphGroup {
            Provides(builder: { (a: BasicTypeA) -> BasicTypeB in
                return .init()
            })
            Provides(builder: { (a: BasicTypeA, b: BasicTypeB) -> BasicTypeC in
                return .init()
            })
            Provides(builder: { (a: BasicTypeA, b: BasicTypeB, c: BasicTypeC) -> BasicTypeD in
                return .init()
            })
            Provides(builder: { (a: BasicTypeA, b: BasicTypeB, c: BasicTypeC, d: BasicTypeD) -> BasicTypeE in
                return .init()
            })
            Provides { (a: BasicTypeA, b: BasicTypeB, c: BasicTypeC, d: BasicTypeD, e: BasicTypeE) -> Foo in
                return .init()
            }
        }
    }
}

final class ProvidesTests: XCTestCase {
    func testProvidesWithBuilder() {
        let container = ComponentContainer(graph: MyComponentGraph())
        XCTAssertNotNil(container.tryGet() as Foo?)
    }
    
    func testUnsatisfiedBuilderProvides() {
        let container = ComponentContainer(graph: MyComponentGraph())
        XCTAssertNil(container.tryGet() as Bar?)
    }
}

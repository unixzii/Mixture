/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class ProvidesTests: XCTestCase {
    func testProvidesWithBuilder() {
        struct MyComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides(value: BasicTypeA())
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
        
        let container = ComponentContainer(graph: MyComponentGraph())
        XCTAssertNotNil(container.tryGet() as Foo?)
    }
}

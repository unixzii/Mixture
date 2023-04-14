/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class UtilityTypeTests: XCTestCase {
    func testAnyComponentGraph() {
        struct MyComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides(value: Foo())
            }
        }
        
        let anyComponentGraph = AnyComponentGraph(erasing: MyComponentGraph())
        let container = ComponentContainer(graph: anyComponentGraph)
        
        XCTAssertNotNil(container.tryGet() as Foo?)
    }
}

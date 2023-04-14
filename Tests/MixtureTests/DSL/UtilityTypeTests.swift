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
    
    func testComponentGraphGroup() {
        struct MyComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                ComponentGraphGroup {
                    Provides(value: Foo())
                    Provides(type: Bar.self)
                }
                ComponentGraphGroup {
                    Provides(value: BasicTypeA())
                    Provides(value: BasicTypeB())
                    Provides(value: BasicTypeC())
                    Provides(value: BasicTypeD())
                    Provides(value: BasicTypeE())
                }
            }
        }
        
        let container = ComponentContainer(graph: MyComponentGraph())
        
        XCTAssertNotNil(container.tryGet() as Foo?)
        XCTAssertNotNil(container.tryGet() as Bar?)
        XCTAssertNotNil(container.tryGet() as BasicTypeA?)
        XCTAssertNotNil(container.tryGet() as BasicTypeB?)
        XCTAssertNotNil(container.tryGet() as BasicTypeC?)
        XCTAssertNotNil(container.tryGet() as BasicTypeD?)
        XCTAssertNotNil(container.tryGet() as BasicTypeE?)
    }
}

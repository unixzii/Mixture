/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class ComponentContainerTests: XCTestCase {
    func testEqualCheck() {
        let container1 = ComponentContainer(graph: EmptyComponentGraphA())
        let container2 = ComponentContainer(graph: EmptyComponentGraphB())
        
        let container1_1 = container1
        
        XCTAssertEqual(container1, container1_1)
        XCTAssertNotEqual(container2, container1_1)
    }
    
    func testUnsatisfiedDependency() {
        struct MyComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Depends(on: SimpleComponentGraph.self)
                
                Provides { (foo: Foo) -> BasicTypeA in
                    return .init()
                }
            }
        }
        
        let simpleContainer = ComponentContainer(graph: SimpleComponentGraph())
        let myContainer = simpleContainer.with {
            ComponentContainer(graph: MyComponentGraph())
        }
        
        XCTAssertNotNil(myContainer.tryGet() as Foo?)
        XCTAssertNotNil(myContainer.tryGet() as BasicTypeA?)
        XCTAssertNil(myContainer.tryGet() as BasicTypeB?)
    }
}

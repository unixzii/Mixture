/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class MixtureTests: XCTestCase {
    func testSimple() {
        let container = ComponentContainer(graph: SimpleComponentGraph())
        
        guard let bar: Bar = container.tryGet() else {
            XCTFail("It should returns a `Bar` instance")
            return
        }
        
        let (fooResult, barResult) = bar.barBehavior()
        XCTAssertTrue(fooResult)
        XCTAssertTrue(barResult)
    }
    
    func testBinding() {
        struct BindingTestComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides(value: Foo())
                
                Binds(Bar.self, to: Baz.self)
            }
        }
        
        let container = ComponentContainer(graph: BindingTestComponentGraph())
        
        guard let bar: Bar = container.tryGet() else {
            XCTFail("It should returns a `Bar` instance")
            return
        }
        
        let (fooResult, barResult) = bar.barBehavior()
        XCTAssertTrue(fooResult)
        XCTAssertFalse(barResult)
    }
    
    func testAssistedInjection() {
        struct FooComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides(value: Foo())
            }
        }
        
        let fooContainer = ComponentContainer(graph: FooComponentGraph())
        
        let barBuilder = AssistedInjectableComponent<Bar>(assistedParams: false)
        guard let bar = barBuilder.createInjectedComponent(with: fooContainer) else {
            XCTFail("It should returns a `Bar` instance")
            return
        }
        
        let (fooResult, barResult) = bar.barBehavior()
        XCTAssertTrue(fooResult)
        XCTAssertFalse(barResult)
    }
    
    func testGraphDependency() {
        struct FooComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides(value: Foo())
            }
        }
        
        struct BarComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Depends(on: FooComponentGraph.self)
                
                Provides(type: Bar.self)
            }
        }
        
        let fooContainer = ComponentContainer(graph: FooComponentGraph())
        let barContainer = fooContainer.with { ComponentContainer(graph: BarComponentGraph()) }
        
        guard let bar: Bar = barContainer.tryGet() else {
            XCTFail("It should returns a `Bar` instance")
            return
        }
        
        let (fooResult, barResult) = bar.barBehavior()
        XCTAssertTrue(fooResult)
        XCTAssertTrue(barResult)
    }
    
    func testCustomGraphType() {
        struct FooComponentGraph: ComponentGraph {
            let fooValue: Bool
            
            var body: some ComponentGraph {
                Provides(value: Foo(value: fooValue))
            }
        }
        
        struct MyTestComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                FooComponentGraph(fooValue: false)
                Provides(type: Bar.self)
            }
        }
        
        let container = ComponentContainer(graph: MyTestComponentGraph())
        
        guard let bar: Bar = container.tryGet() else {
            XCTFail("It should returns a `Bar` instance")
            return
        }
        
        let (fooResult, barResult) = bar.barBehavior()
        XCTAssertFalse(fooResult)
        XCTAssertTrue(barResult)
    }
}

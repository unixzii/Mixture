/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

fileprivate struct _Counter {
    static var fooCreationsCounter: Int = 0
    static var barCreationsCounter: Int = 0
    static var bazCreationsCounter: Int = 0
}

fileprivate class InitLoggingFoo: Foo {
    override init(value: Bool) {
        _Counter.fooCreationsCounter += 1
        super.init(value: value)
    }
}

fileprivate class InitLoggingBaz: Baz {
    required init(injectedWith container: ComponentContainer) {
        _Counter.bazCreationsCounter += 1
        super.init(injectedWith: container)
    }
    
    required init?(injectedWith container: ComponentContainer, params: Bool) {
        _Counter.bazCreationsCounter += 1
        super.init(injectedWith: container, params: params)
    }
}

final class SingletonTests: XCTestCase {
    func testSingleton() {
        struct SingletonTestComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides { () -> Foo in
                    return InitLoggingFoo()
                }
                .singleton()
                
                Provides { (foo: Foo) -> Bar in
                    _Counter.barCreationsCounter += 1
                    return Bar(foo: foo)
                }
                
                Binds(Baz.self, to: InitLoggingBaz.self)
                    .singleton()
            }
        }
        
        struct AnotherComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                Provides { () -> Foo in
                    return InitLoggingFoo()
                }
                .singleton()
                
                Binds(Baz.self, to: InitLoggingBaz.self)
                    .singleton()
            }
        }
        
        _Counter.fooCreationsCounter = 0
        _Counter.barCreationsCounter = 0
        _Counter.bazCreationsCounter = 0
        
        var container = ComponentContainer(graph: SingletonTestComponentGraph())
        
        XCTAssertNotNil(container.tryGet() as Bar?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        XCTAssertEqual(_Counter.barCreationsCounter, 1)
        
        XCTAssertNotNil(container.tryGet() as Foo?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        
        XCTAssertNotNil(container.tryGet() as Bar?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        XCTAssertEqual(_Counter.barCreationsCounter, 2)
        
        XCTAssertNotNil(container.tryGet() as Baz?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        XCTAssertEqual(_Counter.bazCreationsCounter, 1)
        
        // End the lifetime of the previous container.
        container = ComponentContainer(graph: SingletonTestComponentGraph())
        
        XCTAssertNotNil(container.tryGet() as Bar?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        XCTAssertEqual(_Counter.barCreationsCounter, 3)
        
        XCTAssertNotNil(container.tryGet() as Baz?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 1)
        XCTAssertEqual(_Counter.bazCreationsCounter, 1)
        
        // Create a new container with another graph.
        container = ComponentContainer(graph: AnotherComponentGraph())
        
        XCTAssertNotNil(container.tryGet() as Foo?)
        XCTAssertEqual(_Counter.fooCreationsCounter, 2)
        
        XCTAssertNotNil(container.tryGet() as Baz?)
        XCTAssertEqual(_Counter.bazCreationsCounter, 2)
    }
}

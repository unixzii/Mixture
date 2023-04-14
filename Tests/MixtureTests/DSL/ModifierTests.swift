/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class ModifierTests: XCTestCase {
    func testCustomModifier() {
        class Logger {
            var logCount = 0
        }
        
        struct LoggingComponentGraph<T>: ComponentGraph where T: ComponentGraph {
            let graph: T
            let logger: Logger
            
            typealias Body = Never
            
            var body: Never {
                fatalError()
            }
            
            func apply(to container: ComponentContainer) {
                logger.logCount += 1
                guard let modifier = container.modifier(of: LoggingModifier.self) else {
                    XCTFail("The container should return a `LoggingModifier` instance")
                    return
                }
                XCTAssertEqual(ObjectIdentifier(modifier.logger), ObjectIdentifier(logger))
                XCTAssertNil(container.modifier(of: DummyModifier.self))
                graph.apply(to: container)
            }
        }
        
        struct LoggingModifier: ComponentGraphModifier {
            let logger: Logger
            
            func body(content: Content) -> some ComponentGraph {
                LoggingComponentGraph(graph: content, logger: logger)
            }
        }
        
        struct DummyModifier: ComponentGraphModifier {
            func body(content: Content) -> some ComponentGraph {
                content
            }
        }
        
        struct MyComponentGraph: ComponentGraph {
            let logger: Logger
            
            var body: some ComponentGraph {
                Provides(value: Foo())
                    .modifier(modifier: LoggingModifier(logger: logger))
            }
        }
        
        let logger = Logger()
        let container = ComponentContainer(graph: MyComponentGraph(logger: logger))
        
        XCTAssertEqual(logger.logCount, 1)
        XCTAssertNotNil(container.tryGet() as Foo?)
        XCTAssertEqual(logger.logCount, 1)
        
        XCTAssertNil(container.modifier(of: LoggingModifier.self))
    }
}

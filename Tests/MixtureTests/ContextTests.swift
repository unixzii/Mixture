/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class ContextTests: XCTestCase {
    func testContextEnter() {
        let container1 = ComponentContainer(graph: EmptyComponentGraphA())
        let container2 = ComponentContainer(graph: EmptyComponentGraphB())
        
        container1.with {
            container2.with {
                XCTAssertNotNil(Context.shared.container(of: EmptyComponentGraphA.self))
                XCTAssertNotNil(Context.shared.container(of: EmptyComponentGraphB.self))
            }
            
            XCTAssertNotNil(Context.shared.container(of: EmptyComponentGraphA.self))
            XCTAssertNil(Context.shared.container(of: EmptyComponentGraphB.self))
        }
    }
}

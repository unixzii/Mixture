/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import XCTest
@testable import Mixture

final class BuilderTests: XCTestCase {
    func testBuildBlocks() {
        struct MyComponentGraph1: ComponentGraph {
            var body: some ComponentGraph {
                EmptyComponentGraph()
            }
        }
        
        struct MyComponentGraph2: ComponentGraph {
            var body: some ComponentGraph {
                EmptyComponentGraph()
                EmptyComponentGraph()
            }
        }
        
        struct MyComponentGraph3: ComponentGraph {
            var body: some ComponentGraph {
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
            }
        }
        
        struct MyComponentGraph4: ComponentGraph {
            var body: some ComponentGraph {
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
            }
        }
        
        struct MyComponentGraph5: ComponentGraph {
            var body: some ComponentGraph {
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
                EmptyComponentGraph()
            }
        }
        
        // It should compile without errors.
        let _ = ComponentContainer(graph: MyComponentGraph1())
        let _ = ComponentContainer(graph: MyComponentGraph2())
        let _ = ComponentContainer(graph: MyComponentGraph3())
        let _ = ComponentContainer(graph: MyComponentGraph4())
        let _ = ComponentContainer(graph: MyComponentGraph5())
    }
    
    func testBuildBlockWithAnyComponentGraphs() {
        struct MyComponentGraph: ComponentGraph {
            var body: some ComponentGraph {
                // Instantiate graph items more than static-typed `buildBlock` supports.
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
                EmptyComponentGraph().eraseToAnyComponentGraph()
            }
        }
        
        // It should compile without errors.
        let _ = ComponentContainer(graph: MyComponentGraph())
    }
}

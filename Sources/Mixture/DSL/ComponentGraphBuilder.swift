/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

@resultBuilder
public struct ComponentGraphBuilder {
    public static func buildBlock<Graph>(
        _ graph: Graph
    ) -> Graph where Graph: ComponentGraph {
        return graph
    }
}

extension ComponentGraphBuilder {
    public static func buildBlock<E1, E2>(_ e1: E1, _ e2: E2) -> ComponentGraphPair<E1, E2> {
        return .init(first: e1, second: e2)
    }
    
    public static func buildBlock<E1, E2, E3>(_ e1: E1, _ e2: E2, _ e3: E3) -> ComponentGraphPair<E1, ComponentGraphPair<E2, E3>> {
        return .init(first: e1, second: .init(first: e2, second: e3))
    }
    
    public static func buildBlock<E1, E2, E3, E4>(_ e1: E1, _ e2: E2, _ e3: E3, _ e4: E4) -> ComponentGraphPair<E1, ComponentGraphPair<E2, ComponentGraphPair<E3, E4>>> {
        return .init(first: e1, second: .init(first: e2, second: .init(first: e3, second: e4)))
    }
    
    public static func buildBlock<E1, E2, E3, E4, E5>(_ e1: E1, _ e2: E2, _ e3: E3, _ e4: E4, _ e5: E5) -> ComponentGraphPair<E1, ComponentGraphPair<E2, ComponentGraphPair<E3, ComponentGraphPair<E4, E5>>>> {
        return .init(first: e1, second: .init(first: e2, second: .init(first: e3, second: .init(first: e4, second: e5))))
    }
    
    public static func buildBlock(_ graphs: AnyComponentGraph...) -> AnyComponentGraph {
        let firstGraph = graphs.first!
        return graphs.dropFirst().reduce(firstGraph) { partialResult, currentGraph in
            AnyComponentGraph(erasing: ComponentGraphPair(first: partialResult, second: currentGraph))
        }
    }
}

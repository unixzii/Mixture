/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

/// A type-erased component graph.
public struct AnyComponentGraph: ComponentGraph {
    public typealias Body = Never
    
    public let erasedGraph: any ComponentGraph
    
    public var body: Never {
        fatalError()
    }
    
    /// Creates an instance that type-erases `graph`.
    init<T: ComponentGraph>(erasing graph: T) {
        self.erasedGraph = graph
    }
    
    public func apply(to container: ComponentContainer) {
        erasedGraph.apply(to: container)
    }
}

/// A component graph that combines two different graphs.
public struct ComponentGraphPair<T1, T2>: ComponentGraph where T1: ComponentGraph, T2: ComponentGraph {
    public typealias Body = Never
    
    public let first: T1
    public let second: T2
    
    public var body: Never {
        fatalError()
    }
    
    public func apply(to container: ComponentContainer) {
        first.apply(to: container)
        second.apply(to: container)
    }
}

/// A component graph that collects multiple instances of graph type into a single unit.
public struct ComponentGraphGroup<Content>: ComponentGraph where Content: ComponentGraph {
    public let content: Content
    
    public var body: some ComponentGraph {
        content
    }
    
    public init(@ComponentGraphBuilder content: () -> Content) {
        self.content = content()
    }
}

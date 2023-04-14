/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

/// A component graph that defines the dependency of another graph.
public struct Depends<T: ComponentGraph>: ComponentGraph {
    public typealias Body = Never
    
    public let type: T.Type
    
    public var body: Never {
        fatalError()
    }
    
    public init(on type: T.Type) {
        self.type = type
    }
    
    public func apply(to container: ComponentContainer) {
        container.addDependency(type)
    }
}

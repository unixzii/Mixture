/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation

/// A type that contributes the component graph.
/// 
/// You create graphs by declaring types that conform to the `ComponentGraph`
/// protocol. Implement the required `body` computed property to provide the
/// content for your component graph.
///
///     struct MyComponentGraph: ComponentGraph {
///         var body: some ComponentGraph {
///             Provides<Foo>(value: someFoo)
///         }
///     }
///
/// Assemble the graph's body by combining one or more of the built-in graphs
/// provided by Mixture, like the `Provides` instance in the example above.
public protocol ComponentGraph {
    /// The type of graph representing the body of this graph.
    ///
    /// When you create a graph, Swift infers this type from your implementation
    /// of the required `body` property.
    associatedtype Body: ComponentGraph
    
    /// The content of the graph.
    ///
    /// When you implement a graph, you must implement a computed `body`
    /// property to provide the content for your graph. Return a graph that's
    /// composed of built-in graphs that Mixture provides.
    @ComponentGraphBuilder var body: Body { get }
    
    func apply(to container: ComponentContainer)
}

extension ComponentGraph {
    public func apply(to container: ComponentContainer) {
        body.apply(to: container)
    }
}

// Leaf component graph doesn't have a body.
extension Never: ComponentGraph {
    public typealias Body = Never
    
    public var body: Never {
        fatalError()
    }
}

/// A type that represents a fully-formed, connected container for the components
/// that the given graph describes. Users can retrieve or inject components from
/// this container.
public class ComponentContainer: Hashable {
    let graphTypeMatcher: TypeMatcher
    private var dependencyContainers = Set<ComponentContainer>()
    private var providers = Set<ComponentProvider>()
    private var modifierStack = [Any]()
    
    public static func == (lhs: ComponentContainer, rhs: ComponentContainer) -> Bool {
        return lhs === rhs
    }
    
    /// Creates an instance with a graph.
    public init<G: ComponentGraph>(graph: G) {
        graphTypeMatcher = TypeMatcher(type: G.self)
        graph.apply(to: self)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    /// Returns a component of the specified type from this container. The program
    /// will abort if the dependency cannot be satisfied.
    public func `get`<T>() -> T {
        guard let value: T = tryGet() else {
            preconditionFailure("Cannot satisfy the dependency of `\(T.self)`")
        }
        
        return value
    }
    
    /// Returns a component of the specified type from this container, `nil` if the
    /// dependency cannot be satisfied.
    public func tryGet<T>() -> T? {
        let typeMatcher = TypeMatcher(type: T.self)
        for provider in providers {
            if let value = provider.provide(in: self, typeMatcher: typeMatcher) as? T {
                return value
            }
        }
        
        // Try getting the component from our dependencies.
        for dependencyContainer in dependencyContainers {
            if let value: T = dependencyContainer.tryGet() {
                return value
            }
        }
        
        return nil
    }
    
    /// Performs an action with the context of this container.
    ///
    /// You can create sub-containers with dependencies using this method. This can
    /// establish the dependency connection, since there are no directly ways to pass
    /// a container to another one.
    public func with<T>(_ action: () -> T) -> T {
        let context = Context.shared
        context.enter(container: self)
        let value = action()
        context.exit()
        return value
    }
}

// Internal APIs for DSL entities.
extension ComponentContainer {
    func addDependency<T: ComponentGraph>(_ depType: T.Type) {
        guard let container = Context.shared.container(of: depType) else {
            preconditionFailure("Cannot satisfy the dependency of `\(depType)`")
        }
        dependencyContainers.insert(container)
    }
    
    func addProvider(_ provider: ComponentProvider) {
        providers.insert(provider)
    }
    
    func withModifier<T: ComponentGraphModifier, R>(_ modifier: T, _ action: () -> R) -> R {
        modifierStack.append(modifier)
        let value = action()
        let _ = modifierStack.popLast()
        return value
    }
    
    func modifier<T: ComponentGraphModifier>(of type: T.Type) -> T? {
        for modifier in modifierStack.reversed() {
            if let castedModifier = modifier as? T {
                return castedModifier
            }
        }
        return nil
    }
}

public class ComponentProvider: Hashable {
    public static func == (lhs: ComponentProvider, rhs: ComponentProvider) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
        fatalError("Not implemented")
    }
}

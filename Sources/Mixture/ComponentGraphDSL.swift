/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation

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

public protocol _Provider {
    var provider: ComponentProvider { get }
}

class _SingletonComponentProvider: ComponentProvider {
    let provider: ComponentProvider
    var cachedValue: Any?
    
    init(provider: ComponentProvider) {
        self.provider = provider
    }
    
    override func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
        if let cachedValue {
            return cachedValue
        }
        cachedValue = provider.provide(in: container, typeMatcher: typeMatcher)
        return cachedValue
    }
}

public extension ComponentGraph where Self: _Provider {
    func singleton() -> Provides {
        Provides(provider: _SingletonComponentProvider(provider: provider))
    }
    
    func reusable(in scope: Scope) -> Provides {
        Provides(provider: provider)
    }
}

/// A component graph that defines a provider of a component.
///
/// There are 3 ways to provide a component:
/// - Providing a value directly.
/// - Lazily providing a value with injectable type.
/// - Lazily providing a value with a builder, which can also inject dependencies.
public struct Provides: ComponentGraph, _Provider {
    public typealias Body = Never
    
    private class _ClosureComponentProvider<T>: ComponentProvider {
        let closure: (ComponentContainer, TypeMatcher) -> T?
        
        init(closure: @escaping (ComponentContainer, TypeMatcher) -> T?) {
            self.closure = closure
        }
        
        override func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
            return closure(container, typeMatcher)
        }
    }
    
    public let provider: ComponentProvider
    
    public var body: Never {
        fatalError()
    }
    
    fileprivate init(provider: ComponentProvider) {
        self.provider = provider
    }
    
    
    public init<T>(value: T) {
        provider = _ClosureComponentProvider { _, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return value
            }
            return nil
        }
    }
    
    public init<T>(type: T.Type) where T: Injectable {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return T.init(injectedWith: container)
            }
            return nil
        }
    }
    
    public init<T>(builder: @escaping () -> T) {
        provider = _ClosureComponentProvider { _, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder()
            }
            return nil
        }
    }
    
    public init<D, T>(builder: @escaping (D) -> T) {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder(container.get())
            }
            return nil
        }
    }
    
    public func apply(to container: ComponentContainer) {
        container.addProvider(provider)
    }
}

extension Provides {
    public init<D1, D2, T>(builder: @escaping (D1, D2) -> T) {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder(container.get(), container.get())
            }
            return nil
        }
    }
    
    public init<D1, D2, D3, T>(builder: @escaping (D1, D2, D3) -> T) {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder(container.get(), container.get(), container.get())
            }
            return nil
        }
    }
    
    public init<D1, D2, D3, D4, T>(builder: @escaping (D1, D2, D3, D4) -> T) {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder(container.get(), container.get(), container.get(), container.get())
            }
            return nil
        }
    }
    
    public init<D1, D2, D3, D4, D5, T>(builder: @escaping (D1, D2, D3, D4, D5) -> T) {
        provider = _ClosureComponentProvider { container, typeMatcher in
            if typeMatcher.isMatched(with: T.self) {
                return builder(container.get(), container.get(), container.get(), container.get(), container.get())
            }
            return nil
        }
    }
}

/// A component graph that defines a delegate binding.
///
/// For example, to bind `UIViewController` to `MyAwesomeViewController`,
/// a graph could declare:
///
///     Binds(UIViewController.self, to: MyAwesomeViewController.self)
public struct Binds<T, S>: ComponentGraph where S: Injectable {
    private class _BindsComponentProvider: ComponentProvider {
        let sourceType: S.Type
        
        init(sourceType: S.Type) {
            self.sourceType = sourceType
        }
        
        override func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
            if typeMatcher.isMatched(with: T.self) {
                return sourceType.init(injectedWith: container)
            }
            return nil
        }
    }
    
    let provider: ComponentProvider
    
    public init(_ targetType: T.Type, to sourceType: S.Type) {
        provider = _BindsComponentProvider(sourceType: sourceType)
    }
    
    public var body: some ComponentGraph {
        Provides(provider: provider)
    }
}

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
}

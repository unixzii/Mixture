/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

/// A component graph that defines a provider of a component.
///
/// There are 3 ways to provide a component:
/// - Providing a value directly.
/// - Lazily providing a value with injectable type.
/// - Lazily providing a value with a builder, which can also inject dependencies.
public struct Provides: ComponentGraph {
    public typealias Body = Never
    
    private class _ClosureComponentProvider<T>: ComponentProvider {
        let closure: (ComponentContainer, TypeMatcher) -> T?
        
        init(closure: @escaping (ComponentContainer, TypeMatcher) -> T?) {
            self.closure = closure
        }
        
        override func canProvideValue(matched typeMatcher: TypeMatcher) -> Bool {
            return typeMatcher.isMatched(with: T.self)
        }
        
        override func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
            return closure(container, typeMatcher)
        }
    }
    
    public let provider: ComponentProvider
    
    public var body: Never {
        fatalError()
    }
    
    init(provider: ComponentProvider) {
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
        if container.modifier(of: _SingletonModifier.self) != nil {
            container.addProvider(_SingletonComponentProvider(provider: provider))
        } else {
            container.addProvider(provider)
        }
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

public extension ComponentGraph {
    func singleton() -> some ComponentGraph {
        return modifier(modifier: _SingletonModifier())
    }
    
    func reusable(in scope: Scope) -> Never {
        // TODO: TBD
        fatalError("Not implemented")
    }
}

fileprivate class _SingletonComponentManager {
    static let shared = _SingletonComponentManager()
    
    private var records = [Record]()
    
    private struct Record {
        let value: Any
        let graphTypeMatcher: TypeMatcher
    }
    
    func addValue(_ value: Any, inGraphMatched graphTypeMatcher: TypeMatcher) {
        records.append(.init(value: value, graphTypeMatcher: graphTypeMatcher))
    }
    
    func value(matched typeMatcher: TypeMatcher, inGraph graph: Any) -> Any? {
        for record in records {
            guard record.graphTypeMatcher.isMatched(with: graph) else {
                continue
            }
            
            let value = record.value
            if typeMatcher.isMatched(with: value) {
                return value
            }
        }
        return nil
    }
}

fileprivate class _SingletonComponentProvider: ComponentProvider {
    let provider: ComponentProvider
    var cachedValue: Any?
    
    init(provider: ComponentProvider) {
        self.provider = provider
    }
    
    override func provide(in container: ComponentContainer, typeMatcher: TypeMatcher) -> Any? {
        // Fetch the value from our local cache.
        if let cachedValue, typeMatcher.isMatched(with: cachedValue) {
            return cachedValue
        }
        
        // Not hit the cache, try fetching from singleton manager.
        //
        // Before fetching from singleton manager, we must check whether
        // this provider can provide the requested value. For example,
        // if we are requesting a `Foo` value, and it's already existed
        // in singleton manager, then the value will be returned. However,
        // bad things will happen if the callee provider should provide
        // `Bar` values, we may cache the wrong value!
        guard provider.canProvideValue(matched: typeMatcher) else {
            return nil
        }
        
        let manager = _SingletonComponentManager.shared
        if let value = manager.value(matched: typeMatcher, inGraph: container.graph) {
            cachedValue = value
            return value
        }
        
        // First time to access the value, fetch it from the upstream provider.
        // Then store it both to the local cache and singleton manager.
        let value = provider.provide(in: container, typeMatcher: typeMatcher)
        if let value {
            cachedValue = value
            manager.addValue(value, inGraphMatched: container.graphTypeMatcher)
        }
        return value
    }
}

fileprivate struct _SingletonModifier: ComponentGraphModifier {
    func body(content: Content) -> some ComponentGraph {
        content
    }
}

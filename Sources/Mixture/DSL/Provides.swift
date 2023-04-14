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

/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation

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
        if let cachedValue, typeMatcher.isMatched(with: cachedValue) {
            return cachedValue
        }
        let value = provider.provide(in: container, typeMatcher: typeMatcher)
        if value != nil {
            cachedValue = value
        }
        return value
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

public extension ComponentGraph {
    func eraseToAnyComponentGraph() -> AnyComponentGraph {
        .init(erasing: self)
    }
}

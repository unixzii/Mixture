/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation

/// A type that can be constructed via injection.
public protocol Injectable {
    init(injectedWith container: ComponentContainer)
}

/// A type that can be constructed via assisted injection.
public protocol AssistedInjectable {
    associatedtype AssistedParams
    
    init?(injectedWith container: ComponentContainer, params: AssistedParams)
}

/// A helper type that wraps an `AssistedInjectable` type. Users can create
/// component instances with a given container and assisted params.
public struct AssistedInjectableComponent<T> where T: AssistedInjectable {
    public let assistedParams: T.AssistedParams
    
    public init(assistedParams: T.AssistedParams) {
        self.assistedParams = assistedParams
    }
    
    public func createInjectedComponent(with container: ComponentContainer) -> T? {
        return container.with {
            return T.init(injectedWith: container, params: assistedParams)
        }
    }
}

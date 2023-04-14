/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

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

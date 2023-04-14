/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

public struct ComponentGraphModifier_Content: ComponentGraph {
    let content: AnyComponentGraph
    
    public var body: some ComponentGraph {
        content
    }
}

/// A value with a modifier applied to it.
public struct ModifiedContent<Content, Modifier> where Modifier: ComponentGraphModifier {
    /// The content that the modifier transforms into a new modified content.
    public var content: Content
    
    /// The component graph modifier.
    public var modifier: Modifier
}

/// A modifier that you apply to a component graph, producing a different
/// version of the original value.
///
/// Adopt the `ComponentGraphModifier` protocol when you want to create a
/// reusable modifier that you can apply to any component graph.
public protocol ComponentGraphModifier {
    typealias Content = ComponentGraphModifier_Content
    
    associatedtype Body: ComponentGraph
    
    /// Gets the current body of the caller.
    ///
    /// - Parameter content: a proxy for the component graph that will have
    /// the modifier represented by Self applied to it.
    func body(content: Content) -> Body
}

public extension ComponentGraph {
    
    /// Applies a modifier to a component graph and returns a new one.
    /// - Parameter modifier: The modifier to apply to this component graph.
    func modifier<T>(modifier: T) -> ModifiedContent<Self, T> where T: ComponentGraphModifier {
        .init(content: self, modifier: modifier)
    }
    
    /// Returns a type-erased component graph.
    func eraseToAnyComponentGraph() -> AnyComponentGraph {
        .init(erasing: self)
    }
}

extension ModifiedContent: ComponentGraph where Content: ComponentGraph {
    public typealias Body = Never
    
    public var body: Never {
        fatalError()
    }
    
    public func apply(to container: ComponentContainer) {
        container.withModifier(modifier) {
            let content = Modifier.Content(
                content: self.content.eraseToAnyComponentGraph()
            )
            let modifiedContent = self.modifier.body(content: content)
            modifiedContent.apply(to: container)
        }
    }
}

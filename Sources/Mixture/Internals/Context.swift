/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation

// TODO: thread safety
class Context {
    static let shared = Context()
    
    private(set) var enteredContainers = [ComponentContainer]()
    private var _enteredContainers = Set<ObjectIdentifier>()
    
    func enter(container: ComponentContainer) {
        let objectIdentifier = ObjectIdentifier(container)
        if _enteredContainers.contains(objectIdentifier) {
            assertionFailure("Has entered the container!")
            return
        }
        
        _enteredContainers.insert(objectIdentifier)
        enteredContainers.append(container)
    }
    
    func exit() {
        guard let lastContainer = enteredContainers.popLast() else {
            assertionFailure("No container entered!")
            return
        }
        
        _enteredContainers.remove(ObjectIdentifier(lastContainer))
    }
    
    func container<T>(of graphType: T.Type) -> ComponentContainer? {
        for container in enteredContainers {
            if container.graphTypeMatcher.isMatched(with: T.self) {
                return container
            }
        }
        
        return nil
    }
}

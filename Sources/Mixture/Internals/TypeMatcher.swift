/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

struct TypeMatcher {
    private let instanceMatcher: (Any) -> Bool
    private let typeMatcher: (ObjectIdentifier) -> Bool
    
    init<T>(type: T.Type) {
        self.instanceMatcher = {
            return $0 is T
        }
        self.typeMatcher = {
            return $0 == ObjectIdentifier(T.self)
        }
    }
    
    func isMatched(with value: Any) -> Bool {
        return instanceMatcher(value)
    }
    
    func isMatched<T>(with type: T.Type) -> Bool {
        return typeMatcher(ObjectIdentifier(type))
    }
}

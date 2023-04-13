/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Foundation
import Mixture

class Foo {
    let value: Bool
    
    convenience init() {
        self.init(value: true)
    }
    
    init(value: Bool) {
        self.value = value
    }
    
    func fooBehavior() -> Bool {
        return value
    }
}

class Bar: Injectable, AssistedInjectable {
    typealias AssistedParams = Bool
    
    let foo: Foo
    let barValue: Bool
    
    required init(injectedWith container: ComponentContainer) {
        foo = container.get()
        barValue = true
    }
    
    required init?(injectedWith container: ComponentContainer, params: Bool) {
        foo = container.get()
        barValue = params
    }
    
    init(foo: Foo) {
        self.foo = foo
        barValue = true
    }
    
    func barBehavior() -> (Bool, Bool) {
        return (foo.fooBehavior(), barValue)
    }
}

class Baz: Bar {
    override func barBehavior() -> (Bool, Bool) {
        return (foo.fooBehavior(), false)
    }
}

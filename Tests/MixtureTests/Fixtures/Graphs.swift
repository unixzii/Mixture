/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Mixture

struct SimpleComponentGraph: ComponentGraph {
    var body: some ComponentGraph {
        Provides(value: Foo())
        Provides(type: Bar.self)
    }
}

struct EmptyComponentGraphA: ComponentGraph {
    var body: some ComponentGraph {
        EmptyComponentGraph()
    }
}

struct EmptyComponentGraphB: ComponentGraph {
    var body: some ComponentGraph {
        EmptyComponentGraph()
    }
}

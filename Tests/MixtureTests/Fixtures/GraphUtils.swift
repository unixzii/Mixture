/*
 This source file is part of the Mixture open source project

 Copyright (c) 2023 Cyandev and the Mixture project authors
 Licensed under MIT License
*/

import Mixture

struct EmptyComponentGraph: ComponentGraph {
    var body: Never {
        fatalError()
    }
    
    func apply(to container: ComponentContainer) {
        let _ = container
    }
}

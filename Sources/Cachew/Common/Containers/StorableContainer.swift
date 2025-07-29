//
//  Container.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//


final class StorableContainer: Sendable {
    let value: any Storable
    let key: KeyContainer
    
    init(value: some Storable, key: some CachewKey) {
        self.value = value
        self.key = KeyContainer(key)
    }
}

final class Container<Value: Sendable> {
    let value: Value
    
    init(value: Value) {
        self.value = value
    }
}

//
//  Stash.swift
//  Cachew
//
//  Created by Lucas Migge on 12/07/25.
//

import Foundation


public actor Stash<Key: CachewKey, Value: Sendable>: Cache {
    private typealias Cache = NSCache<KeyContainer, Container<Value>>
    
    private let cache = Cache()
    
    public init() {}
    
    public func setValue(_ value: Value, forKey key: Key) {
        let entry = Container(value: value)
        let wrappedKey = KeyContainer(key)
        cache.setObject(entry, forKey: wrappedKey)
    }
    
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = KeyContainer(key)
        let entry = cache.object(forKey: wrappedKey)
        return entry?.value
    }
    
    public func removeValue(forKey key: Key) {
        let wrappedKey = KeyContainer(key)
        cache.removeObject(forKey: wrappedKey)
    }
}

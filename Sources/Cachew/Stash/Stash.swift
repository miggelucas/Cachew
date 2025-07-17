//
//  Stash.swift
//  Cachew
//
//  Created by Lucas Migge on 12/07/25.
//

import Foundation

public actor Stash<Key: CachewKey, Value: Sendable>: Cache {
    
    private let cache = NSCache<WrappedKey, Container<Value>>()
    
    public init() {}
    
    public func setValue(_ value: Value, forKey key: Key) {
        let entry = Container(value: value)
        let wrappedKey = WrappedKey(key)
        cache.setObject(entry, forKey: wrappedKey)
    }
    
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        let entry = cache.object(forKey: wrappedKey)
        return entry?.value
    }
    
    public func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.removeObject(forKey: wrappedKey)
    }
}

extension Stash {
    /// `NSCache` also requires its values to be class objects.
    /// This container wraps our generic `Value` (which could be a struct or other value type).
    private final class Container<T> {
        let value: T
        
        init(value: T) {
            self.value = value
        }
    }
    
    /// `NSCache` requires its keys to be class objects (`NSObject`).
    /// This private wrapper class holds our generic, Hashable `Key`.
    private final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}

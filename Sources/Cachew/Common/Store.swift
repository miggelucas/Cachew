//
//  Store.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//


public protocol Store {
    associatedtype Key: CachewKey
    associatedtype Value: Storable
    
    /// Stores a value in the cache, associated with a given key.
    func setValue(_ value: Value, forKey key: Key) async throws
    
    /// Retrieves a value from the cache for a given key.
    /// - Returns: The cached value, or `nil` if no value is found.
    func value(forKey key: Key) async throws -> Value? 
    
    /// Removes a value from the cache for a given key.
    func removeValue(forKey key: Key) async throws
}

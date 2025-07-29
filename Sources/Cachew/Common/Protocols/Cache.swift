//
//  Storable.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//


/// The public contract for any key-value storage.
/// Key and Value must conform to sendable for Thread-safe measures.
public protocol Cache {
    associatedtype Key: CachewKey
    associatedtype Value: Sendable
    
    /// Stores a value in the cache, associated with a given key.
    func setValue(_ value: Value, forKey key: Key) async
    
    /// Retrieves a value from the cache for a given key.
    /// - Returns: The cached value, or `nil` if no value is found.
    func value(forKey key: Key) async -> Value?
    
    /// Removes a value from the cache for a given key.
    func removeValue(forKey key: Key) async
}


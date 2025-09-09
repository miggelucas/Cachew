//
//  Container.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


final class StorableContainer: Sendable, CacheContainer {
    let value: any Storable
    let keyContainer: any CachewKey
    
    init(value: some Storable, key: some CachewKey) {
        self.value = value
        self.keyContainer = key
    }
}

final class Container<Value: Sendable>: Sendable {
    let value: Value
    
    init(value: Value) {
        self.value = value
    }
}

/// A generic container that can hold any Sendable value with its key
/// This is used by Hydra to support both Storable and non-Storable types
final class ValueContainer: Sendable {
    let value: any Sendable
    let keyContainer: any CachewKey
    
    init(value: some Sendable, key: some CachewKey) {
        self.value = value
        self.keyContainer = key
    }
}

/// A wrapper to make non-Storable Sendable values compatible with Hydra
/// This implements a minimal Storable interface for non-persistent values
final class SendableWrapper: Sendable, Hashable, Codable, Storable {
    let value: any Sendable
    let keyContainer: any CachewKey
    
    // We can't actually encode/decode arbitrary Sendable values
    // But this wrapper allows non-Storable values to work in memory-only mode
    private enum CodingKeys: String, CodingKey {
        case placeholder
    }
    
    init(value: some Sendable, key: some CachewKey) {
        self.value = value
        self.keyContainer = key
    }
    
    // Dummy Codable implementation - will throw if used with storage
    init(from decoder: Decoder) throws {
        fatalError("SendableWrapper cannot be decoded from storage")
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("SendableWrapper cannot be encoded to storage")
    }
    
    static func == (lhs: SendableWrapper, rhs: SendableWrapper) -> Bool {
        return lhs.keyContainer.hashValue == rhs.keyContainer.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyContainer.hashValue)
    }
}

// Protocol to unify StorableContainer and NonStorableWrapper
protocol CacheContainer: Sendable {
    var keyContainer: any CachewKey { get }
}

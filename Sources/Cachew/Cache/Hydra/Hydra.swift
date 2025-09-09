//
//  Hydra.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


public actor Hydra<Key: CachewKey, Value: Sendable>  {
    typealias HydraContainer = StorableContainer
    
    let cache: HydraCacheProtocol
    let storage: HydraStorageProtocol?

    let id: String
    
    private var cacheName: String { cache.name }
    
    // MARK: -Init
    init(
        id: String = UUID().uuidString,
        cache: HydraCacheProtocol = HydraCache(),
        cacheSize: CacheSize = .medium,
        storage: HydraStorageProtocol? = nil
    ) {
        self.id = id
        self.cache = cache
        self.cache.name = id
        self.cache.countLimit = cacheSize.countLimit
        self.storage = storage
        
        self.cache.cacheHandler = self
    }
    
    public init(
        cacheSize: CacheSize = .medium,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.cache = HydraCache()
        self.cache.name = id
        self.cache.countLimit = cacheSize.countLimit
        
        // For now, we'll handle storage dynamically based on the actual values stored
        // Only Storable values will be stored to disk
        self.storage = nil
        
        self.cache.cacheHandler = self
    }
    
    // MARK: -Public cache methods
    public func cacheObject(_ value: Value, forKey key: Key) {
        let wrappedKey = KeyContainer(key)
        
        if let storableValue = value as? any Storable {
            // Value is Storable, use StorableContainer directly
            let entry = StorableContainer(value: storableValue, key: key)
            cache.setObject(entry, forKey: wrappedKey)
        } else {
            // Value is not Storable, wrap it in SendableWrapper
            let wrapper = SendableWrapper(value: value, key: key)
            let entry = StorableContainer(value: wrapper, key: key)
            cache.setObject(entry, forKey: wrappedKey)
        }
    }
    
    public func getObject(forKey key: Key) async -> Value? {
        let wrappedKey = KeyContainer(key)
        guard let cachedObject = cache.object(forKey: wrappedKey) else {
            return await searchForValueOnStorage(forKey: key)
        }
        
        // Check if it's a wrapped non-Storable value
        if let wrapper = cachedObject.value as? SendableWrapper,
           let value = wrapper.value as? Value {
            return value
        }
        // Check if it's a direct Storable value
        else if let value = cachedObject.value as? Value {
            return value
        }
        
        return await searchForValueOnStorage(forKey: key)
    }
    
    public func removeObject(forKey key: Key) async {
        let wrappedKey = KeyContainer(key)
        cache.removeObject(forKey: wrappedKey)
        if let storage = storage, Value.self is any Storable.Type {
            try? await storage.deleteValue(forKey: key)
        }
    }
    
    // MARK: - storage
    
    func storeObject(_ key: Key, _ object: Value) async {
        if let storage = storage, let storableValue = object as? any Storable {
            try? await storage.storeValue(storableValue, forKey: key)
        }
        // Non-Storable values cannot be stored to disk, only kept in memory
    }
    
    func searchForValueOnStorage(forKey key: Key) async -> Value? {
        guard let storage = storage,
              Value.self is any Storable.Type,
              let value = try? await storage.getValue(forKey: key) as? Value
        else { return nil }
        cacheObject(value, forKey: key)
        return value
    }
}

extension Hydra: Cache {
    /// Stores a value in the cache, associated with a given key.
    /// This method makes Hydra compatible with the Cache protocol and allows it to replace Stash
    public func setValue(_ value: Value, forKey key: Key) async {
        cacheObject(value, forKey: key)
    }
    
    /// Retrieves a value from the cache for a given key.
    /// - Returns: The cached value, or `nil` if no value is found.
    public func value(forKey key: Key) async -> Value? {
        return await getObject(forKey: key)
    }
    
    /// Removes a value from the cache for a given key.
    public func removeValue(forKey key: Key) async {
        await removeObject(forKey: key)
    }
}

extension Hydra: CacheHandler {
    nonisolated func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer) {
        Task {
            guard await self.cacheName == cacheName else { return }
            guard let key = object.keyContainer as? Key else { return }
            
            // Handle wrapped non-Storable values
            if let wrapper = object.value as? SendableWrapper,
               let _ = wrapper.value as? Value {
                // Non-Storable values can't be stored, so we just let them be evicted
                return
            }
            // Handle direct Storable values
            else if let value = object.value as? Value {
                await storeObject(key, value)
            }
        }
    }
}


//
//  Hydra.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


public actor Hydra<Key: CachewKey, Value: Storable>  {
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
        self.storage = Silo<Key, Value>()
        self.cache.cacheHandler = self
    }
    
    // MARK: -Public cache methods
    public func cacheObject(_ value: Value, forKey key: Key) {
        let entry = HydraContainer(value: value, key: key)
        let wrappedKey = KeyContainer(key)
        cache.setObject(entry, forKey: wrappedKey)
    }
    
    public func getObject(forKey key: Key) async -> Value? {
        let wrappedKey = KeyContainer(key)
        guard let cachedObject = cache.object(forKey: wrappedKey),
              let value = cachedObject.value as? Value else {
            return await searchForValueOnStorage(forKey: key)
        }
        return value
    }
    
    public func removeObject(forKey key: Key) async {
        let wrappedKey = KeyContainer(key)
        cache.removeObject(forKey: wrappedKey)
        if let storage = storage {
            try? await storage.deleteValue(forKey: key)
        }
    }
    
    // MARK: - storage
    
    func storeObject(_ key: Key, _ object: Value) async {
        if let storage = storage {
            try? await storage.storeValue(object, forKey: key)
        }
    }
    
    func searchForValueOnStorage(forKey key: Key) async -> Value? {
        guard let storage = storage,
              let value = try? await storage.getValue(forKey: key) as? Value
        else { return nil }
        cacheObject(value, forKey: key)
        return value
    }
}

extension Hydra: CacheHandler {
    nonisolated func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer) {
        Task {
            guard await self.cacheName == cacheName else { return }
            guard let key = object.keyContainer as? Key else { return }
            guard let value = object.value as? Value else { return }
            await storeObject(key, value)
        }
    }
}


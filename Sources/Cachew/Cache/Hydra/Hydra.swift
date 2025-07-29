//
//  Hydra.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


public actor Hydra<Key: CachewKey, Value: Storable>  {
    typealias HydraContainer = StorableContainer
    typealias HydraSilo = Silo<Key, Value>
    
    let hydraCache: HydraCacheProtocol
    let silo: HydraSilo?
    let id = UUID()
    
    private var cacheName: String { hydraCache.name }
    
    // MARK: -Init
    init(
        cache: HydraCacheProtocol = HydraCache(),
        cacheSize: CacheSize = .medium,
        silo: (any Store) = HydraSilo(cacheName: UUID().uuidString)
    ) {
        self.hydraCache = cache
        self.hydraCache.countLimit = cacheSize.countLimit
        self.silo = silo as? Silo<Key, Value>
        
        self.hydraCache.cacheHandler = self
    }
    
    public init(cacheSize: CacheSize = .medium) {
        self.silo = HydraSilo(cacheName: id.uuidString)
        self.hydraCache = HydraCache()
        self.hydraCache.countLimit = cacheSize.countLimit
        self.hydraCache.cacheHandler = self
    }
    
    // MARK: -Public methods
    public func setValue(_ value: Value, forKey key: Key) {
        let entry = HydraContainer(value: value, key: key)
        let wrappedKey = KeyContainer(key)
        hydraCache.setObject(entry, forKey: wrappedKey)
    }
    
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = KeyContainer(key)
        guard let cachedObject = hydraCache.object(forKey: wrappedKey),
              let value = cachedObject.value as? Value else { return nil }
        return value
    }
    
    public func removeValue(forKey key: Key) {
        let wrappedKey = KeyContainer(key)
        hydraCache.removeObject(forKey: wrappedKey)
    }
    
    func doSomethingWithObject(_ key: Key, _ object: Value) {
        print("cache did evict object for key: \(key)")
    }
}

extension Hydra: CacheHandler {
    nonisolated func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer) {
        Task {
            guard await self.cacheName == cacheName else { return }
            guard let key = object.key as? Key else { return }
            guard let value = object.value as? Value else { return }
            await doSomethingWithObject(key, value)
        }
    }
}

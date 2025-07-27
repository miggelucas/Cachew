//
//  Hydra.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation



protocol CacheHandler: AnyObject {
    func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer)
}

class HydraCache: NSCache<KeyContainer, StorableContainer>, NSCacheDelegate {
    weak var cacheHandler: (any CacheHandler)?
    
    override
    init() {
        super.init()
        self.delegate = self
    }

    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let container = obj as? StorableContainer, let handler = self.cacheHandler else {
            return
        }
        
        handler.cacheWillRemoveObject(cache.name, container)
    }
}



public actor Hydra<Key: CachewKey, Value: Storable>  {
    typealias HydraContainer = StorableContainer
    typealias HydraSilo = Silo<Key, Value>
    
    let silo: HydraSilo?
    let id = UUID()
    
    let hydraCache: HydraCache
    
    private var cacheName: String { hydraCache.name }
    
    public init(cacheSize: CacheSize = .medium) {
        self.silo = try? HydraSilo(cacheName: id.uuidString)
        self.hydraCache = HydraCache()
        self.hydraCache.countLimit = cacheSize.countLimit
        self.hydraCache.cacheHandler = self
    }
    
    // -- memory cache --
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

extension Hydra {
    public enum CacheSize: Sendable {
        case small
        case medium
        case large
        case extraLarge
        case custom(Int)
        
        var countLimit: Int {
            switch self {
            case .small:
                return 10
            case .medium:
                return 100
            case .large:
                return 1000
            case .extraLarge:
                return 10000
                case .custom(let size):
                return size
            }
        }
    }
}


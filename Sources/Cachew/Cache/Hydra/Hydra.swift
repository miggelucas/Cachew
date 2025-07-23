//
//  Hydra.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


protocol NSCacheDelegateAdaptable: NSObject, NSCacheDelegate {
    var delegate: CacheHandler? { get set }
}

protocol CacheHandler: AnyObject {
    func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer)
}


class NSCCacheDelegateAdapter: NSObject, NSCacheDelegateAdaptable {
    
    weak var delegate: (any CacheHandler)?
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let container = obj as? StorableContainer, let parent = self.delegate else {
            return
        }
        
        print("💧 Hydra Delegate: Pressão de memória detectada! Movendo o item '\(container.key)' para o disco (Silo)...")
        
        parent.cacheWillRemoveObject(cache.name, container)
    }
}

public actor Hydra<Key: CachewKey, Value: Storable>  {
    typealias HydraContainer = StorableContainer
    
    let cache: NSCache<WrappedKey, HydraContainer>
    let cacheAdapter = NSCCacheDelegateAdapter()
    let silo:  Silo<Key, Value>?
    let id = UUID()
    
    private var cacheName: String { cache.name }
    
    public init() {
        self.silo = try? Silo<Key, Value>(cacheName: id.uuidString)
        self.cache = NSCache<WrappedKey, HydraContainer>()
        cache.name = id.uuidString
        cache.delegate = cacheAdapter
        cache.countLimit = 2
        cacheAdapter.delegate = self
    }
    
    // -- memory cache --
    public func setValue(_ value: Value, forKey key: Key) {
        let entry = HydraContainer(value: value, key: key)
        let wrappedKey = WrappedKey(key)
        cache.setObject(entry, forKey: wrappedKey)
    }
    
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        let entry = cache.object(forKey: wrappedKey)
        if let value = entry?.value as? Value {
            return value
        } else {
            return nil
        }
    }
    
    public func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.removeObject(forKey: wrappedKey)
    }
    
    func doSomethingWithObject(_ object: Value) {
        print("opa")
    }
}

extension Hydra: CacheHandler {
    nonisolated func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer) {
        Task {
            guard await self.cacheName == cacheName else { return }
            guard let value = object.value as? Value else { return }
            await doSomethingWithObject(value)
        }
    }
}


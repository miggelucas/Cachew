//
//  HydraCache.swift
//  Cachew
//
//  Created by Lucas Migge on 27/07/25.
//

import Foundation

class HydraCache: NSCache<KeyContainer, StorableContainer>, HydraCacheProtocol, NSCacheDelegate {
    weak var cacheHandler: (any CacheHandler)?
    
    init(cacheHandler: (any CacheHandler)? = nil) {
        super.init()
        self.delegate = self
        self.cacheHandler = cacheHandler
    }
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let container = obj as? StorableContainer,
              let handler = self.cacheHandler else {
            return
        }
        handler.cacheWillRemoveObject(cache.name, container)
    }
}

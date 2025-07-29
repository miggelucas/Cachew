//
//  HydraCacheProtocol.swift
//  Cachew
//
//  Created by Lucas Migge on 27/07/25.
//

import Foundation


protocol HydraCacheProtocol: AnyObject {
    var name: String { get set }
    
    var cacheHandler: (any CacheHandler)? { get set }
    
    func object(forKey key: KeyContainer) -> StorableContainer?
    
    func setObject(_ obj: StorableContainer, forKey key: KeyContainer)
    
    func setObject(_ obj: StorableContainer, forKey key: KeyContainer, cost g: Int)
    
    func removeObject(forKey key: KeyContainer)
    
    func removeAllObjects()
    
    var totalCostLimit: Int { get set }
    
    var countLimit: Int { get set }
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any)
}

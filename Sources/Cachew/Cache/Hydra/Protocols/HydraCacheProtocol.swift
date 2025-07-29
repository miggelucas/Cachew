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
    
    var evictsObjectsWithDiscardedContent: Bool { get set }
}
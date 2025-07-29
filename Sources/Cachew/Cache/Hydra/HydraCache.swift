class HydraCache: NSCache<KeyContainer, StorableContainer>, HydraCacheProtocol, NSCacheDelegate {
    internal init(cacheHandler: (any CacheHandler)?) {
        self.cacheHandler = cacheHandler
    }
    
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

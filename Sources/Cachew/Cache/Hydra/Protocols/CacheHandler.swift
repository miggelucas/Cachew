protocol CacheHandler: AnyObject {
    func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer)
}

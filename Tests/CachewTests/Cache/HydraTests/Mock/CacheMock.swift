//
//  CacheMock.swift
//  Cachew
//
//  Created by Lucas Migge on 27/07/25.
//


final class CacheMock: HydraCacheProtocol, @unchecked Sendable {
    var nameMock = "Mock"
    var name: String {
        get {
            nameMock
        }
        set {
            nameMock = newValue
        }
    }
    
    var cacheHandlerMock: (any CacheHandler)? = nil
    var cacheHandler: (any CacheHandler)? {
        get {
            cacheHandlerMock
        }
        set {
            cacheHandlerMock = newValue
        }
    }
    
    var totalCostLimitMock: Int = 0
    var totalCostLimit: Int {
        get {
            totalCostLimitMock
        }
        set {
            totalCostLimitMock = newValue
        }
    }
    
    var didCallSetCountLimit = false
    var didCallGetCountLimit = false
    var countLimiMock: Int = 0
    var countLimit: Int {
        get {
            didCallGetCountLimit = true
            return countLimiMock
        }
        set {
            didCallSetCountLimit = true
            countLimiMock = newValue
        }
    }
    
    var evictsObjectsWithDiscardedContentMock = false
    var evictsObjectsWithDiscardedContent: Bool {
        get {
            evictsObjectsWithDiscardedContentMock
        }
        set {
            evictsObjectsWithDiscardedContentMock = newValue
        }
    }
    
    var didCallGetObject = false
    var getObjectCalledKey: KeyContainer?
    var getObjectReturn: StorableContainer?
    func object(forKey key: KeyContainer) -> StorableContainer? {
        didCallGetObject = true
        getObjectCalledKey = key
        return getObjectReturn

    }
    
    var didCallSetObject = false
    var setObjectCalledKey: KeyContainer?
    var setObjectCalledValue: StorableContainer?
    func setObject(_ obj: StorableContainer, forKey key: KeyContainer) {
        didCallSetObject = true
        setObjectCalledKey = key
        setObjectCalledValue = obj
    }
    
    var didCallSetObjectWithCost = false
    var setObjectWithCostCalledKey: KeyContainer?
    var setObjectWithCostCalledValue: StorableContainer?
    var setObjectWithCostCalledValueCost: Int?
    func setObject(_ obj: StorableContainer, forKey key: KeyContainer, cost g: Int) {
        didCallSetObjectWithCost = true
        setObjectWithCostCalledKey = key
        setObjectWithCostCalledValue = obj
        setObjectWithCostCalledValueCost = g
    }
    
    var didCallRemoveObject = false
    var removeObjectCalledKey: KeyContainer?
    func removeObject(forKey key: KeyContainer) {
        didCallRemoveObject = true
        removeObjectCalledKey = key
    }
    
    var didCallRemoveObjects = false
    func removeAllObjects() {
        didCallRemoveObjects = true
    }
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        
    }
}
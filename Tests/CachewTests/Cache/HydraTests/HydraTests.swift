//
//  HydraTests.swift
//  Cachew
//
//  Created by Lucas Barros on 22/07/25.
//

import Testing
@testable import Cachew
import Foundation


struct HydraTests {
    
    typealias Sut = Hydra<Int, SomeStorable>
    
    @Suite("Cache (RAM) Unit tests")
    struct CacheUnitTests {
        
        @Test("hydraCache count limit is passed on sut init",
              arguments: [CacheSize.small, .medium, .large, .extraLarge, .custom(50)]
        )
        func HydraCacheCountLimitIsPassedOnSutInit(cacheSize: CacheSize) async throws {
            let cacheMock = CacheMock()
            _ = Sut(cache: cacheMock, cacheSize: cacheSize)
            
            #expect(cacheMock.didCallSetCountLimit)
            #expect(cacheMock.countLimit == cacheSize.countLimit)
        }
        
        @Test("setValue should call setObject for the underlying NSCache")
        func SetValueShouldCallSetObjectForNSCache() async throws {
            let cacheMock = CacheMock()
            let sut = Sut(cache: cacheMock)
            
            let value = SomeStorable(id: 1, name: "Test")
            let key: Int = 1
            
            await sut.cacheObject(value, forKey: key)
            
            #expect(cacheMock.didCallSetObject)
            #expect(cacheMock.setObjectCalledKey == KeyContainer(key))
            #expect(cacheMock.setObjectCalledValue?.value.hashValue == StorableContainer(value: value, key: key).value.hashValue)
        }
        
        @Test("value should call object on the underlying NSCache")
        func ValueShouldCallObjectOnNSCache() async throws {
            let cacheMock = CacheMock()
            let sut = Sut(cache: cacheMock)
            let key: Int = 1
            let value = SomeStorable(id: 1, name: "Test")
            let container = StorableContainer(value: value, key: key)
            cacheMock.getObjectReturn = container
            
            let result = await sut.getObject(forKey: key)
            
            #expect(cacheMock.didCallGetObject)
            #expect(cacheMock.getObjectCalledKey == KeyContainer(key))
            #expect(result == value)
        }
        
        @Test("removeValue should call removeObject on underlying NSCache")
        func RemoveValueShouldCallRemoveObjectOnUnderlyingNSCache() async throws {
            let cacheMock = CacheMock()
            let sut = Sut(cache: cacheMock)
            let key: Int = 1
            
            await sut.removeObject(forKey: key)
            
            #expect(cacheMock.didCallRemoveObject)
            #expect(cacheMock.removeObjectCalledKey == KeyContainer(key))
        }
        
        @Test("Saving to Silo after cache eviction")
        func savesToSiloOnCacheEviction() async throws {
            let cacheMock = CacheMock()
            let storageMock = StorageMock()
            let sut = Sut(id: "TestId", cache: cacheMock, cacheSize: .small, storage: storageMock)
            
            let key = 42
            let value = SomeStorable(id: key, name: "FromRam")
            let storableContainer = StorableContainer(value: value, key: key)
            await sut.cacheObject(value, forKey: key)
            
            sut.cacheWillRemoveObject("TestId", storableContainer)
            
            try await Task.sleep(for: .milliseconds(100))
            #expect(await storageMock.storeValueCalled, "setValue should be called on the silo when removing from cache")
            #expect(await storageMock.lastSavedKey?.hashValue == key.hashValue, "Key saved in the silo should be equal to the one removed from the cache")
            let storedValue = await storageMock.lastSavedValue as? SomeStorable
            #expect(storedValue == value, "Value saved in the silo should be equal to the one removed from the cache")
        }
        
        @Test("Should evict the oldest items when the count limit is reached",
              arguments: [CacheSize.small, .medium, .large, .extraLarge, .custom(5454)])
        func CacheShouldEvictOldestItemsWhenCountLimitReached(cacheSize: CacheSize) async {
            // Arrange
            let storageMock = StorageMock()
            let sut = Sut(cacheSize: cacheSize, storage: storageMock)
            let limit = cacheSize.countLimit
            let itemsToAdd = Int(Double(limit) * 1.1)
            let itemsToEvictCount = itemsToAdd - limit
            
            // Act
            for id in 1...itemsToAdd {
                let item = SomeStorable(id: id, name: "Item \(id)")
                await sut.cacheObject(item, forKey: id)
            }
            
            // Assert
            for id in 1...itemsToEvictCount {
                let value = await sut.getObject(forKey: id)
                #expect(value == nil, "The item \(id), a old one, should be evicted.")
            }
            
            for id in (itemsToEvictCount + 1)...itemsToAdd {
                let value = await sut.getObject(forKey: id)
                #expect(value != nil, "The item \(id), a newest, should not be evicted.")
            }
        }
    }
    
    @Suite("Integration Tests")
    struct IntegrationTest {
        @Test("Accessing an item should protect it from eviction (LRU Policy)")
        func AccessingAnItemShouldProtectItFromEvictionLRUPolicy() async throws {
            // Arrange
            let storageMock = StorageMock()
            let sut = Sut(cacheSize: .custom(4), storage: storageMock)
            
            for id in 1...4 {
                await sut.cacheObject(SomeStorable(id: id, name: "Item \(id)"), forKey: id)
            }
            
            // Act
            let _ = await sut.getObject(forKey: 1)
            await sut.cacheObject(SomeStorable(id: 5, name: "Item 5"), forKey: 5)
            
            // Assert
            let value1 = await sut.getObject(forKey: 1)
            #expect(value1 != nil, "Item 1 shouldn't have been evicted yet since it was accessed recently.")
            
            let value2 = await sut.getObject(forKey: 2)
            #expect(value2 == nil, "Item 2 should have been evicted since it wasn't accessed recently.")
            
            let value3 = await sut.getObject(forKey: 3)
            #expect(value3 != nil, "Item 3 should still be in cache since it was accessed recently.")
            
            let value4 = await sut.getObject(forKey: 4)
            #expect(value4 != nil, "Item 4 should still be in cache since it was accessed recently.")
            
            let value5 = await sut.getObject(forKey: 5)
            #expect(value5 != nil, "Item 5 should still be in cache since it was accessed recently.")
        }
    }
    
    @Test("System should be able to return value for key after cache limit is reached")
    func cacheLimitReached() async throws {
        let sut = Sut(cacheSize: .custom(10))
        
        for id in 1...50 {
            await sut.cacheObject(SomeStorable(id: id,
                                               name: "Item \(id)"),
                                  forKey: id)
        }
        
        try await Task.sleep(for: .milliseconds(50))
        
        for id in 1...10 {
            #expect(await sut.getObject(forKey: id) != nil)
        }
        
        try await Task.sleep(for: .milliseconds(50))
        
        for id in 40...50 {
            #expect(await sut.getObject(forKey: id) != nil)
        }
    }
}


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
            
            await sut.setValue(value, forKey: key)
            
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
            
            let result = await sut.value(forKey: key)
            
            #expect(cacheMock.didCallGetObject)
            #expect(cacheMock.getObjectCalledKey == KeyContainer(key))
            #expect(result == value)
        }
        
        @Test("removeValue should call removeObject on underlying NSCache")
        func RemoveValueShouldCallRemoveObjectOnUnderlyingNSCache() async throws {
            let cacheMock = CacheMock()
            let sut = Sut(cache: cacheMock)
            let key: Int = 1
            
            await sut.removeValue(forKey: key)
            
            #expect(cacheMock.didCallRemoveObject)
            #expect(cacheMock.removeObjectCalledKey == KeyContainer(key))
        }
    }
    
    @Suite("Integration Tests")
    struct IntegrationTest {
        @Test("Should evict the oldest items when the count limit is reached",
              arguments: [CacheSize.small, .medium, .large, .extraLarge, .custom(5454)])
        func CacheShouldEvictOldestItemsWhenCountLimitReached(cacheSize: CacheSize) async {
            // Arrange
            let sut = Sut(cacheSize: cacheSize)
            let limit = cacheSize.countLimit
            let itemsToAdd = Int(Double(limit) * 1.1)
            let itemsToEvictCount = itemsToAdd - limit
            
            // Act
            for id in 1...itemsToAdd {
                let item = SomeStorable(id: id, name: "Item \(id)")
                await sut.setValue(item, forKey: id)
            }
            
            // Assert
            for id in 1...itemsToEvictCount {
                let value = await sut.value(forKey: id)
                #expect(value == nil, "The item \(id), a old one, should be evicted.")
            }
            
            for id in (itemsToEvictCount + 1)...itemsToAdd {
                let value = await sut.value(forKey: id)
                #expect(value != nil, "The item \(id), a newest, should not be evicted.")
            }
        }
        
        @Test("Accessing an item should protect it from eviction (LRU Policy)")
        func AccessingAnItemShouldProtectItFromEvictionLRUPolicy() async throws {
            // Arrange
            let sut = Sut(cacheSize: .custom(4))
            
            for id in 1...4 {
                await sut.setValue(SomeStorable(id: id, name: "Item \(id)"), forKey: id)
            }
            
            // Act
            let _ = await sut.value(forKey: 1)
            await sut.setValue(SomeStorable(id: 5, name: "Item 5"), forKey: 5)
            
            // Assert
            let value1 = await sut.value(forKey: 1)
            #expect(value1 != nil, "Item 1 shouldn't have been evicted yet since it was accessed recently.")
            
            let value2 = await sut.value(forKey: 2)
            #expect(value2 == nil, "Item 2 should have been evicted since it wasn't accessed recently.")
            
            let value3 = await sut.value(forKey: 3)
            #expect(value3 != nil, "Item 3 should still be in cache since it was accessed recently.")
            
            let value4 = await sut.value(forKey: 4)
            #expect(value4 != nil, "Item 4 should still be in cache since it was accessed recently.")
            
            let value5 = await sut.value(forKey: 5)
            #expect(value5 != nil, "Item 5 should still be in cache since it was accessed recently.")
        }
    }
}

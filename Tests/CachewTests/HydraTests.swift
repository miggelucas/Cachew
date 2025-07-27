//
//  HydraTests.swift
//  Cachew
//
//  Created by Lucas Barros on 22/07/25.
//

import Testing
@testable import Cachew

struct HydraTests {
    
    
    typealias Sut = Hydra<Int, SomeStorable>
    
    @Test("Should evict the oldest items when the count limit is reached",
          arguments: [Sut.CacheSize.small, .medium, .large, .extraLarge, .custom(5454)])
    func CacheShouldEvictOldestItemsWhenCountLimitReached(cacheSize: Sut.CacheSize) async {
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
            #expect(value != nil, "Tje item \(id), a newest, should not be evicted.")
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
        #expect(value5 != nil, "Item 3 should still be in cache since it was accessed recently.")
    }
}

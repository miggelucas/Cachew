//
//  StashTests.swift
//  Cachew
//
//  Created by Lucas Migge on 12/07/25.
//

import Testing
@testable import Cachew


@Suite("Stash In-Memory Cache Tests")
struct StashTests {
    
    @Test("Set value should store it in the cache")
    func setValueStoresValue() async throws {
        let cache = Stash<String, String>()
        let key = "testKey"
        let expectedValue = "testValue"
        
        await cache.setValue(expectedValue, forKey: key)
        
        let retrievedValue = await cache.value(forKey: key)
        #expect(retrievedValue == expectedValue)
    }
    
    @Test("Value for a non-existent key should be nil")
    func valueForNonExistentKeyIsNil() async throws {
        let cache = Stash<String, String>()
        let key = "nonExistentKey"
        
        let retrievedValue = await cache.value(forKey: key)
        
        #expect(retrievedValue == nil)
    }
    
    @Test("Remove value should make it nil")
    func removeValueMakesValueNil() async throws {
        // Arrange
        let cache = Stash<String, String>()
        let key = "keyToRemove"
        let value = "valueToRemove"
        await cache.setValue(value, forKey: key)
        
        let valueBeforeRemoval = await cache.value(forKey: key)
        #expect(valueBeforeRemoval != nil)
        
        // Act
        await cache.removeValue(forKey: key)
        
        // Assert
        let valueAfterRemoval = await cache.value(forKey: key)
        #expect(valueAfterRemoval == nil)
    }
    
    @Test("Set value on same key should update current Value")
    func setValueOnSameKeyUpdatesCurrentValue() async throws {
        let cache = Stash<String, String>()
        let key = "keyToUpdate"
        let initialValue = "initialValue"
        await cache.setValue(initialValue, forKey: key)
        
        let valueBeforeUpdate = await cache.value(forKey: key)
        let newValue = "newValue"
        await cache.setValue(newValue, forKey: key)
        let valueAfterUpdate = await cache.value(forKey: key)
        
        #expect(valueAfterUpdate != valueBeforeUpdate)
        #expect(valueAfterUpdate == newValue)
    }
    
}

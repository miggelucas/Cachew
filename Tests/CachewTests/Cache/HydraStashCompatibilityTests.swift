//
//  HydraStashCompatibilityTests.swift
//  Cachew
//
//  Created by Copilot on 09/09/25.
//

import Testing
import Foundation
@testable import Cachew

@Suite("Hydra-Stash Compatibility Tests")
struct HydraStashCompatibilityTests {
    
    @Test("Hydra should work as drop-in replacement for Stash with Sendable types")
    func hydraReplacesStashWithSendableTypes() async throws {
        let cache = Hydra<String, String>()
        let key = "testKey"
        let expectedValue = "testValue"
        
        await cache.setValue(expectedValue, forKey: key)
        
        let retrievedValue = await cache.value(forKey: key)
        #expect(retrievedValue == expectedValue)
    }
    
    @Test("Hydra should handle nil values like Stash")
    func hydraHandlesNilValuesLikeStash() async throws {
        let cache = Hydra<String, String>()
        let key = "nonExistentKey"
        
        let retrievedValue = await cache.value(forKey: key)
        
        #expect(retrievedValue == nil)
    }
    
    @Test("Hydra should remove values like Stash")
    func hydraRemovesValuesLikeStash() async throws {
        let cache = Hydra<String, String>()
        let key = "keyToRemove"
        let value = "valueToRemove"
        await cache.setValue(value, forKey: key)
        
        let valueBeforeRemoval = await cache.value(forKey: key)
        #expect(valueBeforeRemoval != nil)
        
        await cache.removeValue(forKey: key)
        
        let valueAfterRemoval = await cache.value(forKey: key)
        #expect(valueAfterRemoval == nil)
    }
    
    @Test("Hydra should update values like Stash")
    func hydraUpdatesValuesLikeStash() async throws {
        let cache = Hydra<String, String>()
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
    
    @Test("Hydra should work with non-Storable but Sendable types")
    func hydraWorksWithNonStorableTypes() async throws {
        let cache = Hydra<Int, Date>() // Date is Sendable but not our Storable
        let key = 1
        let expectedValue = Date()
        
        await cache.setValue(expectedValue, forKey: key)
        
        let retrievedValue = await cache.value(forKey: key)
        #expect(retrievedValue == expectedValue)
    }
    
    @Test("Hydra should work with custom Sendable struct")
    func hydraWorksWithCustomSendableStruct() async throws {
        struct CustomStruct: Sendable, Equatable {
            let name: String
            let value: Int
        }
        
        let cache = Hydra<String, CustomStruct>()
        let key = "customKey"
        let expectedValue = CustomStruct(name: "test", value: 42)
        
        await cache.setValue(expectedValue, forKey: key)
        
        let retrievedValue = await cache.value(forKey: key)
        #expect(retrievedValue == expectedValue)
    }
}
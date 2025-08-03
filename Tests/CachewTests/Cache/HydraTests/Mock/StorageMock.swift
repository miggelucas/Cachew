//
//  StorageMock.swift
//  Cachew
//
//  Created by Lucas Migge on 03/08/25.
//

@testable import Cachew


actor StorageMock: HydraStorageProtocol {
    var lastSavedKey: (any CachewKey)? = nil
    var lastSavedValue: (any Storable)? = nil
    var storeValueCalled = false
    func storeValue(_ value: some Storable, forKey key: some CachewKey) async throws {
        lastSavedKey = key
        lastSavedValue = value
        storeValueCalled = true
    }
    
    func getValue(forKey key: some CachewKey) async throws -> (any Storable)? {
        return nil
    }
    
    func deleteValue(forKey key: some CachewKey) async throws {
        
    }
}

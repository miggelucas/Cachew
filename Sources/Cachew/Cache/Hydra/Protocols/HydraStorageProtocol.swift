//
//  HydraStorageProtocol.swift
//  Cachew
//
//  Created by Lucas Migge on 03/08/25.
//


protocol HydraStorageProtocol: Sendable {
    func storeValue(_ value: some Storable, forKey key: some CachewKey) async throws
    
    func getValue(forKey key: some CachewKey) async throws -> (any Storable)?
    
    func deleteValue(forKey key: some CachewKey) async throws
}
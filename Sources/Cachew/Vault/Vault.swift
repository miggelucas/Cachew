//
//  Vault.swift
//  Cachew
//
//  Created by Lucas Barros on 19/07/25.
//

import Security
import Foundation


public actor Vault<Key: CachewKey, Value: Storable>: Store {
    
    private let keychain: KeychainServicing
    
    init(keychainService: KeychainServicing) {
        self.keychain = keychainService
    }
    
    public init() {
        self.keychain = KeychainService()
    }
    
    public func setValue(_ value: Value, forKey key: Key) throws {
        let data = try encode(value)
        
        var query: [String: Any] = baseQuery(forKey: key)
        
        // deletes everything under this key to avoid any error by space already been taken
        keychain.delete(query: query)
        
        query[kSecValueData as String] = data
        let status = keychain.add(query: query)
        
        
        if status != errSecSuccess {
            throw VaultError.unhandledError(status: status)
        }
    }
    
    public func value(forKey key: Key) throws -> Value? {
        var query: [String: Any] = baseQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        
        var dataTypeRef: AnyObject?
        let status = keychain.copyMatching(query: query, data: &dataTypeRef)
        
        if status == errSecItemNotFound {
            return nil
        }
        if status != errSecSuccess {
            throw VaultError.unhandledError(status: status)
        }
        
        return try decode(dataTypeRef as? Data)
    }
    
    public func removeValue(forKey key: Key) throws {
        let query = baseQuery(forKey: key)

        let status = keychain.delete(query: query)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw VaultError.unhandledError(status: status)
        }
    }
    
    // MARK: - Helpers
    
    private func baseQuery(forKey key: Key) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
    }
    
    private func encode(_ value: Value) throws -> Data {
        do {
            return try JSONEncoder().encode(value)
        } catch {
            throw VaultError.encodingFailed(error)
        }
    }
    
    private func decode(_ data: Data?) throws -> Value? {
        guard let data else { return nil }
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            throw VaultError.decodingFailed(error)
        }
    }
}

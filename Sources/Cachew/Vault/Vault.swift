//
//  Vault.swift
//  Cachew
//
//  Created by Lucas Barros on 19/07/25.
//

import Security
import Foundation

public enum VaultError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case unhandledError(status: OSStatus)
}

/// KeychainServicing
///
/// Apples have made a pretty shit job with secure data storage since the interaction with the keychain is done by direct open functions and not by some kind of a object with we can make a interface on it.
/// Creating a protocol for making it easer to test Vault by having a dependency injection
public protocol KeychainServicing {
    func add(query: [String: Any]) -> OSStatus
    func copyMatching(query: [String: Any], data: inout CFTypeRef?) -> OSStatus
    @discardableResult
    func delete(query: [String: Any]) -> OSStatus
}

/// KeychainService
///
/// Concrete implementation for the KeychainServicing
/// It was meant to be as dumb as possible and it's only job should create a interface abstracting Security Keychain methods.
public struct KeychainService: KeychainServicing {
    public func add(query: [String: Any]) -> OSStatus {
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    public func update(query: [String: Any], attributes: [String: Any]) -> OSStatus {
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
    
    public func copyMatching(query: [String: Any], data: inout CFTypeRef?) -> OSStatus {
        return SecItemCopyMatching(query as CFDictionary, &data)
        
    }
    
    @discardableResult
    public func delete(query: [String: Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
}



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
        
        // deletes everything under this key to avoid any error by the space already been taken
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
        guard let data = dataTypeRef as? Data else {
            return nil
        }
        return try decode(data)
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
    
    private func decode(_ data: Data) throws -> Value {
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            throw VaultError.decodingFailed(error)
        }
    }
}

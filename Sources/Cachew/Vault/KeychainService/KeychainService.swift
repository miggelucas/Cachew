//
//  KeychainService.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Security


/// KeychainService
///
/// Concrete implementation for the KeychainServicing
/// It was meant to be as dumb as possible and it's only job should create a interface abstracting Security Keychain methods.
public struct KeychainService: KeychainServicing {
    public func add(query: [String: Any]) -> OSStatus {
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    public func copyMatching(query: [String: Any], data: inout CFTypeRef?) -> OSStatus {
        return SecItemCopyMatching(query as CFDictionary, &data)
    }
    
    @discardableResult
    public func delete(query: [String: Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
}

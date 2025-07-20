//
//  KeychainServicing.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Security


/// KeychainServicing
///
/// The Keychain API uses direct functions rather than object-oriented interfaces, making it challenging to abstract for testing purposes.
/// This protocol facilitates testing of the Vault by enabling dependency injection.
public protocol KeychainServicing {
    func add(query: [String: Any]) -> OSStatus
    func copyMatching(query: [String: Any], data: inout CFTypeRef?) -> OSStatus
    @discardableResult
    func delete(query: [String: Any]) -> OSStatus
}

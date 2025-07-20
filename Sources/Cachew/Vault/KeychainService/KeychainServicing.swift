//
//  for.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Security


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

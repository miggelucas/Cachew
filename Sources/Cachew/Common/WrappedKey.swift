//
//  WrappedKey.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


/// `NSCache` requires its keys to be class objects (`NSObject`).
/// This private wrapper class holds our generic, Hashable `Key`.
final class WrappedKey: NSObject, Sendable {
    let key: any CachewKey
    
    init(_ key: any CachewKey) { self.key = key }
    
    override var hash: Int { return key.hashValue }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let value = object as? WrappedKey else {
            return false
        }
        return value.key.hashValue == key.hashValue
    }
}

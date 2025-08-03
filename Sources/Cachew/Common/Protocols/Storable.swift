//
//  Storable.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//


public protocol Storable: Sendable & Codable & Hashable where Self: Equatable {}

extension Storable {
    static public func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}



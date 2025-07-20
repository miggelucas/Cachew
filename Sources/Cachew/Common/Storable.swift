//
//  Storable.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//


public protocol Storable: Sendable & Codable {
    var cacheKey: any CachewKey { get }
}


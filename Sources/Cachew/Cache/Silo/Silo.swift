//
//  Silo.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//

import Foundation

public actor Silo<Key: CachewKey, Value: Storable>: Store {
    
    private let fileManager: FileManagerProtocol
    var cacheName: String
    var directoryURL: URL
    
    /// The designated initializer. It performs the main setup and allows for dependency injection, making it testable.
    ///
    /// - Parameters:
    ///   - siloName: A unique name for the cache directory (e.g., "images", "articles").
    ///   - fileManager: The file manager to use for all disk operations.
    init(cacheName: String? = nil, fileManager: FileManagerProtocol) {
        self.fileManager = fileManager
        self.cacheName = cacheName ?? UUID().uuidString
        
        let cacheDirectory: URL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        self.directoryURL = cacheDirectory.appendingPathComponent(self.cacheName, isDirectory: true)
        if !fileManager.fileExists(atPath: self.directoryURL.path) {
            try? fileManager.createDirectory(at: self.directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// A convenience initializer for ease of use in a production environment.
    /// It automatically uses the default file manager.
    ///
    /// - Parameter siloName: A unique name for the cache directory.
    public init(cacheName: String? = nil) {
        self.init(cacheName: cacheName, fileManager: FileManager.default)
    }
    
    // MARK: - Storable Conformance
    
    public func setValue(_ value: Value, forKey key: Key) throws {
        let data = try JSONEncoder().encode(value)
        try fileManager.write(data: data, to: fileURL(forKey: key))
    }
    
    public func value(forKey key: Key) throws -> Value? {
        let fileURL = fileURL(forKey: key)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        let data = try fileManager.readData(from: fileURL)
        return try JSONDecoder().decode(Value.self, from: data)
    }
    
    public func removeValue(forKey key: Key) throws {
        let fileURL = fileURL(forKey: key)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public func size() throws -> Double {
        return try fileManager.sizeOfDirectory(at: directoryURL)
    }
    
    // MARK: - Internal Helpers
    func fileURL(forKey key: Key) -> URL {
        let fileName = String(describing: key.hashValue)
        return directoryURL.appendingPathComponent(fileName)
    }
}

extension Silo: HydraStorageProtocol {
    func storeValue(_ value: some Storable, forKey key: some CachewKey) async throws {
        guard let object = value as? Value,
              let key = key as? Key else { return }
        try setValue(object, forKey: key)
    }
    
    func getValue(forKey key: some CachewKey) async throws -> (any Storable)? {
        guard let key = key as? Key else { return nil }
        return try value(forKey: key)
    }
    
    func deleteValue(forKey key: some CachewKey) async throws {
        guard let key = key as? Key else { return }
        try removeValue(forKey: key)
    }
}

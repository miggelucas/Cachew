//
//  FileManagerProtocol.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//

import Foundation


public protocol FileManagerProtocol {
    var temporaryDirectory: URL { get }
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func sizeOfDirectory(at url: URL) throws -> Double
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    
    // delegating methods from Data type for unique access to behavior
    func write(data: Data, to url: URL) throws
    func readData(from url: URL) throws -> Data
}


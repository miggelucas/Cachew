//
//  FileManagerMock.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//

@testable import Cachew
import Foundation


final class FileManagerMock: FileManagerProtocol, @unchecked Sendable {
    var didCallTemporaryDirectory: Bool = false
    var temporaryDirectoryMock = URL(fileURLWithPath: "test")
    var temporaryDirectory: URL {
        didCallTemporaryDirectory = true
        return temporaryDirectoryMock
    }
    
    // Simulates the file system: [FilePath: FileData]
    var files: [String: Data] = [:]
    var directories: Set<String> = []
    var didCallCreateDirectory = false
        
    let directoryURL = URL(fileURLWithPath: "test")
    var shouldFailToFindCacheDirectory = false
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        
        if shouldFailToFindCacheDirectory {
            return []
        } else {
            return [directoryURL]
        }
    }
    
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws {
        didCallCreateDirectory = true
        directories.insert(url.path)
    }
    
    func fileExists(atPath path: String) -> Bool {
        return files[path] != nil || directories.contains(path)
    }
    
    func removeItem(at URL: URL) throws {
        files.removeValue(forKey: URL.path)
    }
    
    func contents(atPath path: String) -> Data? {
        return files[path]
    }

    func write(data: Data, to url: URL) {
        files[url.path] = data
    }
    
    func readData(from url: URL) throws -> Data {
        return files[url.path] ?? Data()
    }
    
    func sizeOfDirectory(at url: URL) throws -> Double {
        return 0
    }
}

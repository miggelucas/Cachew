//
//  FileManager.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Foundation


extension FileManager: FileManagerProtocol {
 
    
    public func write(data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
    
    public func readData(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
    
    /// Calculates the total size of a directory, including all its subdirectories and files.
    ///
    /// - Parameter url: The URL of the directory to measure.
    /// - Returns: The total size in bytes (UInt64), or `nil` if the directory cannot be read.
    public func sizeOfDirectory(at url: URL) throws -> Double {
        var totalSize: UInt64 = 0
        
        guard let enumerator = self.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: .skipsHiddenFiles
        ) else {
            print("Error: Could not create enumerator for directory.")
            throw SiloError.cacheDirectoryMissing
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let values = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
                totalSize += UInt64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
            } catch {
                print("Error obtaining the size of file \(fileURL.path): \(error)")
                throw SiloError.cacheDirectoryMissing
            }
        }
        
        return Double(totalSize)
    }
}

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
}

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
    
    /// Calcula o tamanho total de um diretório, incluindo todos os seus subdiretórios e arquivos.
    ///
    /// - Parameter url: A URL do diretório que você quer medir.
    /// - Returns: O tamanho total em bytes (UInt64), ou `nil` se o diretório não puder ser lido.
    public func sizeOfDirectory(at url: URL) throws -> Double {
        var totalSize: UInt64 = 0
        
        guard let enumerator = self.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: .skipsHiddenFiles
        ) else {
            print("Erro: Não foi possível criar o enumerador para o diretório.")
            throw SiloError.cacheDirectoryMissing
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let values = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
                totalSize += UInt64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
            } catch {
                print("Erro ao obter o tamanho do arquivo \(fileURL.path): \(error)")
                throw SiloError.cacheDirectoryMissing
            }
        }
        
        return Double(totalSize)
    }
}

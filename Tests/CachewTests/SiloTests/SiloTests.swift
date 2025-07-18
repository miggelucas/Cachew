//
//  SiloTests.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//

import Testing
import Foundation
@testable import Cachew


@Suite("Silo (Disk Cache) Tests")
final class SiloTests {
        
    private let siloName = "TestCache"
    
    @Test("Initialization should create cache directory")
    func initCreatesDirectory() throws {
        // Arrange
        let fileManager = FileManagerMock()
        
        // Act
        let _ = try Silo<String, User>(cacheName: siloName, fileManager: fileManager)
        
        // Assert
        #expect(fileManager.didCallCreateDirectory == true)
        let expectedPath = fileManager.directoryURL.appendingPathComponent(siloName).path
        #expect(fileManager.directories.contains(expectedPath))
    }
    
    @Test("Initialization should throw directoryCreationFailed error when directory is not found")
    func initThrowsErrorWhenDirectoryNotFound() {
        // Arrange
        let fileManager = FileManagerMock()
        fileManager.shouldFailToFindDirectory = true
        
        #expect(throws: SiloError.cacheDirectoryMissing) {
            _ = try Silo<String, User>(cacheName: self.siloName, fileManager: fileManager)
        }
        #expect(SiloError.cacheDirectoryMissing.errorDescription?.isEmpty == false, "Should have some error description")
    }
    
    @Test("setValue should use fileManager to write data")
    func setValueWritesData() async throws {
        // Arrange
        let fileManager = FileManagerMock()
    
        let sut: Silo<String, User> = try Silo(cacheName: siloName, fileManager: fileManager)
        let user = User(id: 1, name: "John Snow")
        let key = "user1"
        
        // Act
        try await sut.setValue(user, forKey: key)
        
        // Assert
        let fileURL = await sut.fileURL(forKey: key)
        let dataWritten = fileManager.files[fileURL.path]
        #expect(dataWritten != nil)
        
        let decodedUser = try JSONDecoder().decode(User.self, from: dataWritten!)
        #expect(decodedUser == user)
    }
    
    @Test("value should use fileManager to read and decode data")
    func valueReadsData() async throws {
        // Arrange
        let fileManager = FileManagerMock()
        let sut: Silo<String, User> = try Silo(cacheName: siloName, fileManager: fileManager)
        let user = User(id: 2, name: "Daenerys Targaryen")
        let key = "user2"
        
        // Prepara o mock: coloca os dados diretamente no sistema de arquivos virtual.
        let data = try JSONEncoder().encode(user)
        let fileURL = await sut.fileURL(forKey: key)
        fileManager.files[fileURL.path] = data
        
        // Act
        let retrievedUser = try await sut.value(forKey: key)
        
        // Assert
        #expect(retrievedUser != nil)
        #expect(retrievedUser == user)
    }
    
    @Test("value for a non-existent key should return nil")
    func valueForNonExistentKeyReturnsNil() async throws {
        // Arrange
        let fileManager = FileManagerMock()
        let sut: Silo<String, User> = try Silo(cacheName: siloName, fileManager: fileManager)
        let key = "nonExistentKey"
        
        // Act
        let retrievedUser = try await sut.value(forKey: key)
        
        // Assert
        #expect(retrievedUser == nil)
    }
    
    @Test("removeValue should use fileManager to delete the file")
    func removeValueDeletesFile() async throws {
        // Arrange
        let fileManager = FileManagerMock()
        let sut: Silo<String, User> = try Silo(cacheName: siloName, fileManager: fileManager)
        let user = User(id: 3, name: "Tyrion Lannister")
        let key = "user3"
        
        // Prepara o mock
        let data = try JSONEncoder().encode(user)
        let fileURL = await sut.fileURL(forKey: key)
        fileManager.files[fileURL.path] = data
        #expect(fileManager.files[fileURL.path] != nil, "Pré-condição: o arquivo deve existir antes da remoção.")
        
        // Act
        try await sut.removeValue(forKey: key)
        
        // Assert
        #expect(fileManager.files[fileURL.path] == nil, "O arquivo deveria ter sido removido do mock.")
    }
}

extension SiloTests {
    // Representable storable object
    private struct User: Storable, Equatable {
        let id: Int
        let name: String
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
}

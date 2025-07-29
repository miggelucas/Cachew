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
        
    typealias Sut = Silo<String, SomeStorable>
    private let siloName = "TestCache"
    
    @Test("Initialization should create cache directory")
    func initCreatesDirectory() throws {
        // Arrange
        let fileManager = FileManagerMock()
        
        // Act
        let _ = Sut(cacheName: siloName, fileManager: fileManager)
        
        // Assert
        #expect(fileManager.didCallCreateDirectory)
        let expectedPath = fileManager.directoryURL.appendingPathComponent(siloName).path
        #expect(fileManager.directories.contains(expectedPath))
    }
    
    @Test("if initialization with cacheDirectory fails should use temporary directory")
    func initThrowsErrorWhenDirectoryNotFound() {
        // Arrange
        let fileManager = FileManagerMock()
        fileManager.shouldFailToFindCacheDirectory = true
        
        // Act
        let _ = Sut(cacheName: siloName, fileManager: fileManager)
       
        // Assert
        #expect(fileManager.didCallTemporaryDirectory)
        #expect(fileManager.didCallCreateDirectory)
        let expectedPath = fileManager.temporaryDirectory.appending(path: siloName).path()
        #expect(fileManager.directories.contains(expectedPath))
    }
    
    @Test("setValue should use fileManager to write data")
    func setValueWritesData() async throws {
        // Arrange
        let fileManager = FileManagerMock()
    
        let sut = Sut(cacheName: siloName, fileManager: fileManager)
        let user = SomeStorable(id: 1, name: "John Snow")
        let key = "user1"
        
        // Act
        try await sut.setValue(user, forKey: key)
        
        // Assert
        let fileURL = await sut.fileURL(forKey: key)
        let dataWritten = fileManager.files[fileURL.path]
        #expect(dataWritten != nil)
        
        let decodedUser = try JSONDecoder().decode(SomeStorable.self, from: dataWritten!)
        #expect(decodedUser == user)
    }
    
    @Test("value should use fileManager to read and decode data")
    func valueReadsData() async throws {
        // Arrange
        let fileManager = FileManagerMock()
        let sut = Sut(cacheName: siloName, fileManager: fileManager)
        let user = SomeStorable(id: 2, name: "Daenerys Targaryen")
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
        let sut = Sut(cacheName: siloName, fileManager: fileManager)
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
        let sut = Sut(cacheName: siloName, fileManager: fileManager)
        let user = SomeStorable(id: 3, name: "Tyrion Lannister")
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



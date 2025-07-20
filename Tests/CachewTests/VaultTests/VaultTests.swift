//
//  VaultTests.swift
//  Cachew
//
//  Created by Lucas Barros on 19/07/25.
//

import Testing
import Foundation
@testable import Cachew

import Security

final class KeychainServiceMock: KeychainServicing, @unchecked Sendable {
    var didCallAdd: Bool = false
    var addQuery: [String : Any]?
    var addResult: OSStatus = noErr
    func add(query: [String : Any]) -> OSStatus {
        didCallAdd = true
        addQuery = query
        return addResult
    }
    
    var didCallUpdate: Bool = false
    var updateQuery: [String : Any]?
    var updateAttributes: [String : Any]?
    var updateResult: OSStatus = noErr
    func update(query: [String : Any], attributes: [String : Any]) -> OSStatus {
        didCallUpdate = true
        updateQuery = query
        updateAttributes = attributes
        return updateResult
    }
    
    var didCallCopyMatching: Bool = false
    var copyMatchingQuery: [String : Any]?
    var copyMatchingData: CFTypeRef?
    var copyMatchingResult: OSStatus = noErr
    func copyMatching(query: [String : Any], data: inout CFTypeRef?) -> OSStatus {
        didCallCopyMatching = true
        copyMatchingQuery = query
        data = copyMatchingData
        return copyMatchingResult
    }
    
    var didCallDelete: Bool = false
    var deleteQuery: [String : Any]?
    var deleteResult: OSStatus = noErr
    func delete(query: [String : Any]) -> OSStatus {
        didCallDelete = true
        deleteQuery = query
        return deleteResult
    }
}


@Suite("Vault (Keychain) Tests")
struct VaultTests {
    
    typealias VaultContainer = Vault<String, SomeStorable>
    
    @Test("setValue should store a value in the keychainService")
    func SetValueShouldCallMethods() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let user = SomeStorable(id: 1, name: "MySuperSecretToken")
        let key = "testUser1"
        
        // Act
        try await sut.setValue(user, forKey: key)
        
        // Assert
        #expect(keychainServiceMock.didCallDelete, "Should call delete before add")
        #expect(keychainServiceMock.didCallAdd)
        #expect(keychainServiceMock.addQuery?.isEmpty == false)
    }
    
    @Test("getValue should call the getValue method of the keychainService")
    func getValue() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let user = SomeStorable(id: 1, name: "MySuperSecretToken")
        let key = "testUser1"
        
        keychainServiceMock.copyMatchingData = try JSONEncoder().encode(user) as CFTypeRef
        keychainServiceMock.copyMatchingResult = errSecSuccess
        // Act
        let retrievedUser = try await sut.value(forKey: key)
        
        // Assert
        #expect(keychainServiceMock.didCallCopyMatching)
        #expect(keychainServiceMock.copyMatchingQuery?.isEmpty == false)
        #expect(retrievedUser == user)
    }
    
    @Test("removeValue should call the removeValue method of the keychainService")
    func removeValue() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "testUser3"
        
        // Act
        try await sut.removeValue(forKey: key)
        
        // Assert
        #expect(keychainServiceMock.didCallDelete)
        #expect(keychainServiceMock.deleteQuery?[kSecAttrAccount as String] as? String == key)
    }
    
    // MARK: -Integration tests
    // using concrete keychain implementation
    // serialized for avoiding interference between tests
    @Suite("Vault Integration Tests", .serialized)
    struct IntegrationTest {
        
        // reverting keychain state to be called at the end of the tests
        private func cleanup(forKey key: String) async {
            let cleanupVault = VaultContainer()
            try? await cleanupVault.removeValue(forKey: key)
        }
        
        @Test("removeValue for a non-existent key should not throw an error")
        func removeNonExistentValue() async throws {
            // Arrange
            let sut = VaultContainer()
            let key = "alreadyGoneUser"
            
            // Act & Assert
            await #expect(throws: Never.self, performing: {
                try await sut.removeValue(forKey: key)
            })
            
            // Revert
            await cleanup(forKey: key)
        }
        
        @Test("value for a non-existent key should return nil")
        func valueForNonExistentKeyReturnsNil() async throws {
            // Arrange
            let sut = VaultContainer()
            let key = "nonExistentUser"
            
            // Act
            let retrievedUser = try await sut.value(forKey: key)
            
            // Assert
            #expect(retrievedUser == nil)
            // Revert
            await cleanup(forKey: key)
        }
        
        @Test("value should retrieve a value from the keychainService")
        func value() async throws {
            let sut = VaultContainer()
            let key = "testUser1"
            let user = SomeStorable(id: 1, name: "Gal Costa")
            
            await #expect(throws: Never.self, performing: {
                try await sut.setValue(user, forKey: key)
            })
            
            // Act
            let retrievedUser = try await sut.value(forKey: key)
            
            // Assert
            #expect(retrievedUser == user)
            // Revert
            await cleanup(forKey: key)
        }
        
        @Test("setValue IT")
        func SetValueIT() async throws {
            // Arrange
            let sut = VaultContainer()
            let user = SomeStorable(id: 1, name: "MySuperSecretToken")
            let key = "testUser1"
            
            
            // Act
            await #expect(throws: Never.self, performing: {
                try await sut.setValue(user, forKey: key)
            })
            
            // Revert
            await cleanup(forKey: key)
        }
    }
}

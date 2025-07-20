//
//  VaultTests.swift
//  Cachew
//
//  Created by Lucas Barros on 19/07/25.
//

import Testing
import Security
import Foundation
@testable import Cachew


@Suite("Vault (Keychain) Tests")
struct VaultTests {
    
    typealias VaultContainer = Vault<String, SomeStorable>
    
    
    @Test("setValue should call add method on the keychainService")
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
    
    @Test("setValue should thrown Error if status from keychain is different than errSecSuccess")
    func SetValueShouldThrownErrorIfStatusIsDifferentThanSuccess() async throws {
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let user = SomeStorable(id: 1, name: "MySuperSecretToken")
        let key = "testUser1"
        
        keychainServiceMock.addResult = errSecDuplicateItem
        
        await #expect(throws: VaultError.self, performing: {
            try await sut.setValue(user, forKey: key)
        })
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
    
    @Test("getValue should not throw an error when keychain status its errSecItemNotFound")
    func getValueNotThrowsErrorIfOSStatusItsErrSecItemNotFound() async throws {
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "someKey"
        
        keychainServiceMock.copyMatchingResult = errSecItemNotFound
        
        await #expect(throws: Never.self, performing: {
            try await sut.value(forKey: key)
        })
    }
    
    @Test("getValue should throw an error when keychain status its not success")
    func getValueThrowsErrorIfOSStatusItsNotSuccess() async throws {
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "someKey"
        
        keychainServiceMock.copyMatchingResult = errSecInvalidItemRef
        
        await #expect(throws: VaultError.self, performing: {
            try await sut.value(forKey: key)
        })
    }
    
// Removed duplicate test `getValueThrowsError` as it is identical to `getValueThrowsErrorIfOSStatusItsNotSuccess`.
    
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
        
        
        @Test("setValue should store a value in the keychainService and be able to retrieve it")
        func SetValueAndRetriveIT() async throws {
            // Arrange
            let sut = VaultContainer()
            let user = SomeStorable(id: 1, name: "MySuperSecretToken")
            let key = "testUser1"
            
            // Act
            await #expect(throws: Never.self, performing: {
                try await sut.setValue(user, forKey: key)
            })
            
            let retrievedUser = try await sut.value(forKey: key)
            #expect(retrievedUser == user)
            
            // Revert
            await cleanup(forKey: key)
        }
        
        @Test("Deleting a existing key should return nil when retrieving")
        func DeletingValueShouldReturnNilWhenRetriving() async throws {
            // Arrange
            let sut = VaultContainer()
            let user = SomeStorable(id: 1, name: "MySuperSecretToken")
            let key = "testUser1"
            
            // Act
            await #expect(throws: Never.self, performing: {
                try await sut.setValue(user, forKey: key)
                try await sut.removeValue(forKey: key)
            })
            
            // Assert
            let retrievedUser = try await sut.value(forKey: key)
            #expect(retrievedUser == nil)
            
            // Revert
            await cleanup(forKey: key)
        }
    }
}

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
    var copyMatchingResult: (OSStatus, CFTypeRef?) = (noErr, nil)
    func copyMatching(query: [String : Any]) -> (status: OSStatus, result: CFTypeRef?) {
        return (errSecItemNotFound, nil)
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
        #expect(keychainServiceMock.didCallAdd)
        #expect(keychainServiceMock.addQuery?.isEmpty == false)
    }
    
    @Test("setValue IT")
    func SetValueIT() async throws {
        // Arrange
        let sut = VaultContainer()
        let user = SomeStorable(id: 1, name: "MySuperSecretToken")
        let key = "testUser1"
        
        // Act
        try await sut.setValue(user, forKey: key)
    }
    
    @Test("setValue should update an existing value in the keychain")
    func updateValue() async throws {
        // Arrange
        let sut = VaultContainer()
        let key = "testUser2"
        let initialUser = SomeStorable(id: 2, name: "Tralalero Tralala")
        let updatedUser = SomeStorable(id: 2, name: "Bailarina Cappucina")
        
        // Act
        try await sut.setValue(initialUser, forKey: key)
        try await sut.setValue(updatedUser, forKey: key)
        
        // Assert
        let retrievedUser = try await sut.value(forKey: key)
        #expect(retrievedUser == updatedUser)
    }
    
    @Test("value should retrieve a value from the keychainService")
    func value() async throws {
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "testUser1"
        let user = SomeStorable(id: 1, name: "Gal Costa")
        
    }
    



    @Test("value for a non-existent key should return nil")
    func valueForNonExistentKeyReturnsNil() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "nonExistentUser"
        
        // Act
        let retrievedUser = try await sut.value(forKey: key)
        
        // Assert
        #expect(retrievedUser == nil)
    }

    @Test("removeValue should delete the item from the keychain")
    func removeValue() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let user = SomeStorable(id: 3, name: "ToBeDeleted")
        let key = "testUser3"
        try await sut.setValue(user, forKey: key)
        
        // Garante que o valor existe antes de remover
        #expect(try await sut.value(forKey: key) != nil)
        
        // Act
        try await sut.removeValue(forKey: key)
        
        // Assert
        let retrievedUser = try await sut.value(forKey: key)
        #expect(retrievedUser == nil)
    }
    
    @Test("removeValue for a non-existent key should not throw an error")
    func removeNonExistentValue() async throws {
        // Arrange
        let keychainServiceMock = KeychainServiceMock()
        let sut = VaultContainer(keychainService: keychainServiceMock)
        let key = "alreadyGoneUser"
        
        // Act & Assert
        // A chamada não deve lançar um erro. Se lançar, o teste falhará.
        try await sut.removeValue(forKey: key)
    }
}

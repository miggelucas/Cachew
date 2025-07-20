//
//  KeychainServiceMock.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

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

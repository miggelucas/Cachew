//
//  VaultError.swift
//  Cachew
//
//  Created by Lucas Barros on 20/07/25.
//

import Security


public enum VaultError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case unhandledError(status: OSStatus)
}

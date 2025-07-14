//
//  SiloError.swift
//  Cachew
//
//  Created by Lucas Migge on 13/07/25.
//

import Foundation


public enum SiloError: Error, LocalizedError {
    case cacheDirectoryMissing
        
    public var errorDescription: String? {
        switch self {
        case .cacheDirectoryMissing: return "Could not find cache directory"
        }
    }
}

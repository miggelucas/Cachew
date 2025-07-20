//
//  SomeStorable.swift
//  Cachew
//
//  Created by Lucas Barros on 19/07/25.
//

import Cachew
import Foundation


/// SomeStorable
///
/// Sample object for testing purposes
struct SomeStorable: Storable, Equatable {
    let id: Int
    let name: String
    let data: Data?
    
    var cacheKey: any CachewKey {
        return id
    }
    
    init(id: Int, name: String, data: Data? = nil) {
        self.id = id
        self.name = name
        self.data = data
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.data == rhs.data
    }
}

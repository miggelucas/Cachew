//
//  Double.swift
//  Cachew
//
//  Created by Lucas Barros on 18/07/25.
//

import Foundation


extension Duration {
    var asTimeInterval: TimeInterval {
        TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1_000_000_000_000_000_000
    }
}

//
//  Clock.swift
//  Cachew
//
//  Created by Lucas Barros on 18/07/25.
//

import Foundation

enum Clock {
    static func measure(_ work: () async throws -> Void) async rethrows -> (TimeInterval) {
        let start = DispatchTime.now()
        try await work()
        let end = DispatchTime.now()
        let duration = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        return (duration)
    }
}

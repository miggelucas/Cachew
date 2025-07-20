import Testing
import Foundation
@testable import Cachew


// MARK: - Performance tests
@Suite("Performance Tests")
struct PerformanceTests {
    private typealias StashContainer = Stash<String, SomeStorable>
    private typealias SiloContainer = Silo<String, SomeStorable>
    
    private let operationCount_Stash = 10_000
    
    private let operationCount_Stats = 100
    private let sampleCount_Stats = 30
    private let tCriticalValue = 3.0
    
    @Test("Stash write and read performance")
    func stashPerformance() async throws {
        let clock = ContinuousClock()
        let stash = StashContainer()
        let users = (0..<operationCount_Stash).map {
            SomeStorable(id: $0, name: "User \($0)", data: Data(repeating: 1, count: Int.random(in: 100..<100_000)))
        }
        
        let writeTime = await clock.measure {
            for user in users {
                await stash.setValue(user, forKey: String(user.id))
            }
        }
        print("StashTest - Time to write \(operationCount_Stash) Objects: \(writeTime) seconds")

        let readTime = await clock.measure {
            for user in users {
                _ = await stash.value(forKey: String(user.id))
            }
        }
        print("StashTest - Time to read \(operationCount_Stash) Objects: \(readTime) seconds")
        
        #expect(writeTime.components.seconds < 1 && readTime.components.seconds < 1, "Stash Memory should be fast enough for this test")
    }
    
    @Test("Stash vs. Silo statistical performance comparison")
    func statisticalComparison() async throws {
        
        let clock = ContinuousClock()
        
        var stashWriteDurations: [TimeInterval] = []
        var stashReadDurations: [TimeInterval] = []
        var siloWriteDurations: [TimeInterval] = []
        var siloReadDurations: [TimeInterval] = []
        
        print("Initializing statistical performance test for \(sampleCount_Stats) samples...")
        
        for i in 1...sampleCount_Stats {
            print("StatsTest - Running sample \(i)/\(sampleCount_Stats)...")
            
            // --- Stash Test ---
            let stash = StashContainer()
            let users = (0..<operationCount_Stats).map {
                SomeStorable(id: $0,
                     name: "User \($0)",
                     data: Data(repeating: UInt8.random(in: 0...255),
                                count: Int.random(in: 1000...10_000))
                )
            }
            
            // Stash write
            let stashWriteTime = await clock.measure {
                for user in users {
                    await stash.setValue(user, forKey: String(user.id))
                }
            }
            stashWriteDurations.append(stashWriteTime.asTimeInterval)
            
            // Stash Read
            let stashReadTime = await clock.measure {
                for j in 0..<operationCount_Stats {
                    _ = await stash.value(forKey: String(j))
                }
            }
            stashReadDurations.append(stashReadTime.asTimeInterval)
            
            // --- Silo Test ---
            let silo = try SiloContainer(cacheName: "StatTestSilo_\(i)")
            
            // Silo Write
            let siloWriteTime = try await clock.measure {
                for user in users {
                    try await silo.setValue(user, forKey: String(user.id))
                }
            }
            siloWriteDurations.append(siloWriteTime.asTimeInterval)
            
            // Silo Read
            let siloReadTime = try await clock.measure {
                for j in 0..<operationCount_Stats {
                    _ = try await silo.value(forKey: String(j))
                }
            }
            siloReadDurations.append(siloReadTime.asTimeInterval)
        
            try? await FileManager.default.removeItem(at: silo.directoryURL)
        }
        
        // --- Processing results ---
        
        let stashWriteAverage = Statistics.mean(stashWriteDurations)
        let stashReadAverage = Statistics.mean(stashReadDurations)
        let siloWriteAverage = Statistics.mean(siloWriteDurations)
        let siloReadAverage = Statistics.mean(siloReadDurations)
        
        print("\n--- Final Results (Average of \(sampleCount_Stats) runs) ---")
        print(String(format: "Stash - Average write time: %.4f seconds", stashWriteAverage))
        print(String(format: "Stash - Average read time:  %.4f seconds", stashReadAverage))
        print("--------------------------------------------------")
        print(String(format: "Silo  - Average write time: %.4f seconds", siloWriteAverage))
        print(String(format: "Silo  - Average read time:  %.4f seconds", siloReadAverage))
        print("--------------------------------------------------\n")
        
        let writeTValue = Statistics.tStatistic(sample1: stashWriteDurations, sample2: siloWriteDurations)
        let readTValue = Statistics.tStatistic(sample1: stashReadDurations, sample2: siloReadDurations)
        
        print("--- Statistical Analysis (t-test) ---")
        print(String(format: "t-value for write (Stash vs. Silo): %.4f", writeTValue))
        print(String(format: "t-value for read (Stash vs. Silo):  %.4f", readTValue))
        print("----------------------------------------\n")
        
        
        #expect(abs(writeTValue) > tCriticalValue, "The average write time for Stash is not significantly lower than Silo's.")
        #expect(abs(readTValue) > tCriticalValue, "The average read time for Stash is not significantly lower than Silo's.")
    }
}




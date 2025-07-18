import Testing
import Foundation
@testable import Cachew


// MARK: - Performance tests
@Suite("Performance Tests")
struct PerformanceTests {
    private let operationCount_Stash = 10_000
    
    private let operationCount_Stats = 100
    private let sampleCount_Stats = 30
    private let tNegativeCriticalValue = -3.0
    
    @Test("Stash write and read performance")
    func stashPerformance() async throws {
        let stash = Stash<String, User>()
        let users = (0..<operationCount_Stash).map { User(id: $0, name: "User \($0)") }
        
        let writeStartTime = Date()
        for user in users {
            await stash.setValue(user, forKey: String(user.id))
        }
        let writeEndTime = Date()
        let writeDuration = writeEndTime.timeIntervalSince(writeStartTime)
        print("StashTest - Time to write \(operationCount_Stash) Objects: \(writeDuration) seconds")

        let readStartTime = Date()
        for i in 0..<operationCount_Stash {
            _ = await stash.value(forKey: String(i))
        }
        let readEndTime = Date()
        let readDuration = readEndTime.timeIntervalSince(readStartTime)
        print("StashTest - Time to read \(operationCount_Stash) Objects: \(readDuration) seconds")
        
        #expect(writeDuration < 1 && readDuration < 1, "Stash Memory should be fast enough for this test")
    }
    
    @Test("Stash vs. Silo statistical performance comparison")
    func statisticalComparison() async throws {
        var stashWriteDurations: [TimeInterval] = []
        var stashReadDurations: [TimeInterval] = []
        var siloWriteDurations: [TimeInterval] = []
        var siloReadDurations: [TimeInterval] = []
        
        print("Initializing statistical performance test for \(sampleCount_Stats) samples...")
        
        for i in 1...sampleCount_Stats {
            print("StatsTest - Running sample \(i)/\(sampleCount_Stats)...")
            
            // --- Stash Test ---
            let stash = Stash<String, User>()
            let users = (0..<operationCount_Stats).map { User(id: $0, name: "User \($0)") }
            
            // Stash write
            let stashWriteStart = Date()
            for user in users {
                await stash.setValue(user, forKey: String(user.id))
            }
            stashWriteDurations.append(Date().timeIntervalSince(stashWriteStart))
            
            // Stash Read
            let stashReadStart = Date()
            for j in 0..<operationCount_Stats {
                _ = await stash.value(forKey: String(j))
            }
            stashReadDurations.append(Date().timeIntervalSince(stashReadStart))
            
            // --- Silo Test ---
            let silo = try Silo<String, User>(cacheName: "StatTestSilo_\(i)")
            
            // Silo Write
            let siloWriteStart = Date()
            for user in users {
                try await silo.setValue(user, forKey: String(user.id))
            }
            siloWriteDurations.append(Date().timeIntervalSince(siloWriteStart))
            
            // Silo Read
            let siloReadStart = Date()
            for j in 0..<operationCount_Stash {
                _ = try await silo.value(forKey: String(j))
            }
            siloReadDurations.append(Date().timeIntervalSince(siloReadStart))
            
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
        
        #expect(writeTValue < tNegativeCriticalValue, "The average write time for Stash is not significantly lower than Silo's.")
        #expect(readTValue < tNegativeCriticalValue, "The average read time for Stash is not significantly lower than Silo's.")
    }
}

extension PerformanceTests {
    private struct User: Storable {
        let id: Int
        let name: String
        let someData: Data
        
        init(id: Int, name: String) {
            self.id = id
            self.name = name
            self.someData = Data(repeating: 1, count: 100_000)
        }
    }
}

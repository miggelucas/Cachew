//
//  Statistics.swift
//  Cachew
//
//  Created by Lucas Migge on 17/07/25.
//

import Foundation


struct Statistics {
    static func mean(_ data: [Double]) -> Double {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0, +) / Double(data.count)
    }
    
    static func variance(_ data: [Double]) -> Double {
        guard data.count > 1 else { return 0 }
        let meanValue = mean(data)
        let sumOfSquaredDifferences = data.reduce(0) { (result, value) in
            let difference = value - meanValue
            return result + difference * difference
        }
        return sumOfSquaredDifferences / Double(data.count - 1)
    }
    
    static func tStatistic(sample1: [Double], sample2: [Double]) -> Double {
        let mean1 = mean(sample1)
        let mean2 = mean(sample2)
        let variance1 = variance(sample1)
        let variance2 = variance(sample2)
        let n1 = Double(sample1.count)
        let n2 = Double(sample2.count)
        
    
        let numerator = mean1 - mean2
        let denominator = sqrt((variance1 / n1) + (variance2 / n2))
        
        guard denominator != 0 else { return 0 }
        
        return numerator / denominator
    }
}

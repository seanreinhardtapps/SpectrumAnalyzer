//
//  Frequency.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation


struct Frequency: Codable, Identifiable {
    var id: String
    var db: Double
    
    func freq() -> String {
        return "\(id)"
    }
}

struct FrequencyResponse:Codable {
    var response: [Frequency]
}

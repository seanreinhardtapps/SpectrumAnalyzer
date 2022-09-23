//
//  Frequency.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation


public struct Frequency: Codable, Identifiable {
    public var id: String
    public var db: Float
    
    public func freq() -> String {
        return "\(id)"
    }
}

public struct FrequencyResponse:Codable {
    public var response: [Frequency]
}

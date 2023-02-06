//
//  FrequencyResponse.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 2/5/23.
//

import Foundation

public struct FrequencyResponse:Codable {
    public var response: [Frequency]
    
    init(response:[Frequency]) {
        self.response = response
    }
    
    init(autoSpectrum: [Float]) {
        self.response = []
        for (index, value) in autoSpectrum.enumerated() {
            if index % 100 == 0 {
                self.response.append(Frequency(index: index, db: value))
            }
        }
    }
}

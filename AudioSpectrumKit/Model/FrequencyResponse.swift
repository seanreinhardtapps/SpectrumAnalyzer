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
    
    init(autoSpectrum: [Float], bucketSize:Double) {
        self.response = []
        for (index, value) in autoSpectrum.enumerated() {
            self.response.append(Frequency(index: index, db: value, bucketSize: bucketSize))
        }
    }
}

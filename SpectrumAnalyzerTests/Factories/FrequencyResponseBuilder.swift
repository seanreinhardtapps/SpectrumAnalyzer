//
//  FrequencyResponseBuilder.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation

class FrequencyResponseBuilder {
    static func flatResponse() -> FrequencyResponse {

        return FrequencyResponse.init(response: [
            Frequency(id: "60hz", db: 10.0),
            Frequency(id: "100hz", db: 10.0),
            Frequency(id: "150hz", db: 10.0),
            Frequency(id: "200hz", db: 10.0),
            Frequency(id: "250hz", db: 10.0),
            Frequency(id: "350hz", db: 10.0),
            Frequency(id: "500hz", db: 10.0),
            Frequency(id: "700hz", db: 10.0),
            Frequency(id: "850hz", db: 10.0),
            Frequency(id: "1khz", db: 10.0),
            Frequency(id: "1.5khz", db: 10.0),
            Frequency(id: "2khz", db: 10.0),
            Frequency(id: "3khz", db: 10.0),
            Frequency(id: "4khz", db: 10.0),
            Frequency(id: "5khz", db: 10.0),
            Frequency(id: "7.5khz", db: 10.0),
            Frequency(id: "10khz", db: 10.0),
            Frequency(id: "12khz", db: 10.0),
            Frequency(id: "14khz", db: 10.0),
            Frequency(id: "16khz", db: 10.0),
        ])
    }
}

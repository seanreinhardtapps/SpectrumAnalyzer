//
//  FrequencyResponseBuilder.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
public class FrequencyResponseBuilder {
    public static func flatResponse() -> FrequencyResponse {
        return FrequencyResponse(response: [
            Frequency(index: 60, db: 10.0),
            Frequency(index: 100, db: 10.0),
            Frequency(index: 150, db: 10.0),
            Frequency(index: 200, db: 10.0),
            Frequency(index: 250, db: 10.0),
            Frequency(index: 350, db: 10.0),
            Frequency(index: 500, db: 10.0),
            Frequency(index: 700, db: 10.0),
            Frequency(index: 850, db: 10.0),
            Frequency(index: 1000, db: 10.0),
            Frequency(index: 1500, db: 10.0),
            Frequency(index: 2000, db: 10.0),
            Frequency(index: 3000, db: 10.0),
            Frequency(index: 4000, db: 10.0),
            Frequency(index: 5000, db: 10.0),
            Frequency(index: 7500, db: 10.0),
            Frequency(index: 10000, db: 10.0),
            Frequency(index: 12000, db: 10.0),
            Frequency(index: 14000, db: 10.0),
            Frequency(index: 16000, db: 10.0),
        ])
    }
}

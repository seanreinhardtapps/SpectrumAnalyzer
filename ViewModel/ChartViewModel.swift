//
//  ChartViewModel.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import Combine

class ChartViewModel: ObservableObject {
    
    @Published var data:[Frequency]
    
    init() {
        data = FrequencyResponseBuilder.flatResponse().response
    }
}

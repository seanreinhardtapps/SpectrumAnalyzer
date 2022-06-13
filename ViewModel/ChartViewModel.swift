//
//  ChartViewModel.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import Combine
import AudioSpectrumKit
class ChartViewModel: ObservableObject {
    
    @Published var data:[Frequency]
    var audioSampler: AudioSpectrumKit?
    init() {
        data = FrequencyResponseBuilder.flatResponse().response
        audioSampler = AudioSpectrumKit.init()
        audioSampler?.start()
    }
}

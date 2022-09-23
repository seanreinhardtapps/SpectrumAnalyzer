//
//  ChartViewModel.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import Combine
import AudioSpectrumKit
class ChartViewModel: NSObject, ObservableObject, AudioSpectrumKitResultsDelegate {
    
    @Published var data:[Frequency]
    var audioSampler: AudioSpectrumKit?
    override init() {
        data = FrequencyResponseBuilder.flatResponse().response
        super.init()
        audioSampler = AudioSpectrumKit.init(delegate: self)
        audioSampler?.start()
    }
    
    func didReceiveSample(frequencyResponse: FrequencyResponse) {
        DispatchQueue.main.async {
            self.data = frequencyResponse.response
        }
    }
    
    func samplingFailedToStart(error: Error) {
        
    }
    
    func samplingFailedToSetup(error: Error) {
        
    }
    
}

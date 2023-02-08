//
//  ChartViewModel.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import Combine
import AudioSpectrumKit
class ChartViewModel: NSObject, ObservableObject {
    
    var subscription:[AnyCancellable] = []
    @Published var data:[Frequency]
    var audioSampler: AudioSpectrumKit?
    override init() {
        data = []
        super.init()
        audioSampler = AudioSpectrumKit.init()
        audioSampler?.startPublish().sink(receiveValue: { frequencyResponse in
            self.data = frequencyResponse.response
        }).store(in: &subscription)
    }
    
}

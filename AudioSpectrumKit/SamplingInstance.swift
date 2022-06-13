//
//  SamplingInstance.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import AVFoundation

class SamplingInstance {
    
    let engine:AVAudioEngine
    let audioSession:AVAudioSession
    
    init(engine: AVAudioEngine = AVAudioEngine(),
         audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.engine = engine
        self.audioSession = audioSession
    }
    
    func sample() {
        
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) {(buffer, time) in
            buffer.floatChannelData
            print("\(time) \(buffer.floatChannelData)")
            let channelData = buffer.floatChannelData![0]
            let arr = Array(UnsafeBufferPointer(start:channelData, count: 4096))
            print(arr)
        }
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
    }
}


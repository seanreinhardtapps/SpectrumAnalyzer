//
//  SamplingInstance.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import AVFoundation

protocol AudioSamplingInstanceDelegate: NSObject {
    func sampleProcessed(result:FrequencyResponse)
}

class SamplingInstance {
    static let DefaultWorkerQueue:DispatchQueue = DispatchQueue(label: "com.seanreinhardtapps.workerqueue")
    weak var delegate: AudioSamplingInstanceDelegate?
    let engine:AVAudioEngine
    let audioSession:AVAudioSession
    let frameSize: AVAudioFrameCount
    let sampleRate:Double
    let powerSpectrum: PowerSpectrumCalculation
    let workerQueue:DispatchQueue
    
    init(delegate:AudioSamplingInstanceDelegate,
         sampleSize: UInt,
         powerSpectrum:PowerSpectrumCalculation,
         engine: AVAudioEngine = AVAudioEngine(),
         audioSession: AVAudioSession = AVAudioSession.sharedInstance(),
         queue:DispatchQueue = DefaultWorkerQueue) {
        self.delegate = delegate
        self.powerSpectrum = powerSpectrum
        self.engine = engine
        self.audioSession = audioSession
        self.frameSize = AVAudioFrameCount(sampleSize)
        self.workerQueue = queue
        self.sampleRate = audioSession.sampleRate
    }
    
    func sample() {
        workerQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let inputNode = self.engine.inputNode
            let format = inputNode.inputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: self.frameSize, format: format) { [weak self] (buffer, time) in
                self?.onTap(buffer, time)
            }
            self.engine.prepare()
            do {
                try self.engine.start()
            } catch {
                print(error)
            }
        }
    }

    func onTap(_ buffer: AVAudioPCMBuffer, _ time:AVAudioTime) {
        guard let data = buffer.floatChannelData else {
            return
        }
        Task {
            let channelData = Array(UnsafeBufferPointer(start: data[0], count: Int(buffer.frameLength)))
            let response = await self.powerSpectrum.execute(discreteSignal: channelData,
                                                            sampleRate: self.sampleRate)
            delegate?.sampleProcessed(result: response)
        }
    }
}

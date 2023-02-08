//
//  AudioSpectrumKit.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import UIKit
import AVFoundation
private let microphonePermissionKey = "NSMicrophoneUsageDescription"

public protocol AudioSpectrumKitResultsDelegate: NSObject {
    func didReceiveSample(frequencyResponse:FrequencyResponse)
    func samplingFailedToStart(error:Error)
    func samplingFailedToSetup(error:Error)
}

public class AudioSpectrumKit: NSObject, AudioSamplingInstanceDelegate {
    
    internal var sampleRate:UInt = 16384
    var delegate: AudioSpectrumKitResultsDelegate?
    internal var audioSession: AVAudioSession
    
    internal var samplingInstance: SamplingInstance?
    public init(delegate: AudioSpectrumKitResultsDelegate? = nil,
                audioSession: AVAudioSession = AVAudioSession.sharedInstance(),
                bundle:Bundle = Bundle.main) {
        self.delegate = delegate
        self.audioSession = audioSession
        super.init()
        do {
            try audioSession.setCategory(.playAndRecord)
            //try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true)
        } catch {
            delegate?.samplingFailedToSetup(error: error)
        }
        if !verifyRecordingPermissionKey(bundle: bundle) {
            delegate?.samplingFailedToSetup(error: AudioSpectrumKitErrorFactory.plistError())
            return
        }
        
        self.samplingInstance = SamplingInstance(delegate: self,
                                                 rate: sampleRate,
                                                 powerSpectrum: FFTPowerSpectrum(n: sampleRate),
                                                 //powerSpectrum: DCTPowerSpectrum(n: Int(sampleRate)),
                                                 audioSession: self.audioSession)
    }
    
    func verifyRecordingPermissionKey(bundle:Bundle) -> Bool {
        if let info = bundle.infoDictionary, let permissionKey = info[microphonePermissionKey] as? String {
            return permissionKey.count > 0
        }
        return false
    }
    
    public func start() {
        weak var weakSelf = self
        audioSession.requestRecordPermission { (granted) -> Void in
            if !granted {
                OperationQueue.main.addOperation {
                    if let strongSelf = weakSelf {
                        strongSelf.delegate?.samplingFailedToSetup(error: AudioSpectrumKitErrorFactory.permissionError())
                    }
                }
                return
            }
            if let instance = weakSelf?.samplingInstance {
                instance.sample()
            }
        }
    }
    
    func sampleProcessed(result: FrequencyResponse) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didReceiveSample(frequencyResponse: result)
        }
    }
}

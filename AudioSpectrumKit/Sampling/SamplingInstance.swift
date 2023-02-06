//
//  SamplingInstance.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation
import AVFoundation
import Accelerate

protocol AudioSamplingInstanceDelegate: NSObject {
    func sampleProcessed(result:FrequencyResponse)
}

class SamplingInstance {
    
    weak var delegate: AudioSamplingInstanceDelegate?
    let engine:AVAudioEngine
    let audioSession:AVAudioSession
    let n:Int
    let frameCount: AVAudioFrameCount
    let powerSpectrum: FFTPowerSpectrum
    
    init(delegate:AudioSamplingInstanceDelegate,
         rate: UInt,
         powerSpectrum:FFTPowerSpectrum,
         engine: AVAudioEngine = AVAudioEngine(),
         audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.delegate = delegate
        self.powerSpectrum = powerSpectrum
        self.engine = engine
        self.audioSession = audioSession
        self.frameCount = AVAudioFrameCount(rate)
        self.n = Int(rate)
    }
    
    func sample() {
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: frameCount, format: format) { [weak self] (buffer, time) in
            self?.onTap(buffer, time)
        }
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
    }

    func onTap(_ buffer: AVAudioPCMBuffer, _ time:AVAudioTime) {
        guard let data = buffer.floatChannelData else {
            return
        }
        let channelData = Array(UnsafeBufferPointer(start: data[0], count: n))
        self.powerSpectrum.execute(discreteSignal: channelData) { [weak self] response in
            guard let self = self,
                    let delegate = self.delegate else {
                return
            }
            delegate.sampleProcessed(result: response)
        }
    }
}

typealias PowerSpectrumCompletion = ((FrequencyResponse) -> Void)
class FFTPowerSpectrum {
    let n: UInt
    lazy var halfN = Int(n / 2)
    lazy var log2n = vDSP_Length(log2(Float(n)))
    
    lazy var fft = vDSP.FFT(log2n: log2n,
                            radix: .radix2,
                            ofType: DSPSplitComplex.self)
    init(n:UInt) {
        self.n = vDSP_Length(n)
        self.halfN = halfN
    }
    
    func execute(discreteSignal:[Float], _ completion:PowerSpectrumCompletion) {
        var forwardInputReal = [Float](repeating: 0, count: halfN)
        var forwardInputImag = [Float](repeating: 0, count: halfN)
        var forwardOutputReal = [Float](repeating: 0, count: halfN)
        var forwardOutputImag = [Float](repeating: 0, count: halfN)

        forwardInputReal.withUnsafeMutableBufferPointer { forwardInputRealPtr in
            forwardInputImag.withUnsafeMutableBufferPointer { forwardInputImagPtr in
                forwardOutputReal.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
                    forwardOutputImag.withUnsafeMutableBufferPointer { forwardOutputImagPtr in
                        
                        // Create a `DSPSplitComplex` to contain the signal.
                        var forwardInput = DSPSplitComplex(realp: forwardInputRealPtr.baseAddress!,
                                                           imagp: forwardInputImagPtr.baseAddress!)
                        
                        // Convert the real values in `signal` to complex numbers.
                        discreteSignal.withUnsafeBytes {
                            vDSP.convert(interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                                         toSplitComplexVector: &forwardInput)
                        }
                        
                        // Create a `DSPSplitComplex` to receive the FFT result.
                        var forwardOutput = DSPSplitComplex(realp: forwardOutputRealPtr.baseAddress!,
                                                            imagp: forwardOutputImagPtr.baseAddress!)
                        
                        if let fft = fft {
                            fft.forward(input: forwardInput, output: &forwardOutput)
                        }
                        
                    }
                }
            }
        }
        let autoSpectrum = self.computePowerDensity(realOutput: &forwardOutputReal,
                                                    imaginaryOutput: &forwardOutputImag)
        completion(FrequencyResponse(autoSpectrum: autoSpectrum))
    }
    
    func computePowerDensity(realOutput:inout [Float], imaginaryOutput:inout [Float]) -> [Float] {
        let autospectrum = [Float](unsafeUninitializedCapacity: halfN) {
            autospectrumBuffer, initializedCount in
            
            // The `vDSP_zaspec` function accumulates its output. Clear the
            // uninitialized `autospectrumBuffer` before computing the spectrum.
            vDSP.clear(&autospectrumBuffer)
            
            realOutput.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
                imaginaryOutput.withUnsafeMutableBufferPointer { forwardOutputImagPtr in
                    
                    var frequencyDomain = DSPSplitComplex(realp: forwardOutputRealPtr.baseAddress!,
                                                          imagp: forwardOutputImagPtr.baseAddress!)
                    
                    vDSP_zaspec(&frequencyDomain,
                                autospectrumBuffer.baseAddress!,
                                vDSP_Length(halfN))
                }
            }
            initializedCount = halfN
        }
        return autospectrum
    }
}

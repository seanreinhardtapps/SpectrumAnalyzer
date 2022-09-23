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
    func sampleProcessed(result:[Float])
}

class SamplingInstance {
    
    weak var delegate: AudioSamplingInstanceDelegate?
    let engine:AVAudioEngine
    let audioSession:AVAudioSession
    let n = vDSP_Length(4096)
    lazy var halfN = Int(n / 2)
    lazy var log2n = vDSP_Length(log2(Float(n)))

    
    lazy var fftSetUp = vDSP.FFT(log2n: log2n,
                                  radix: .radix2,
                                  ofType: DSPSplitComplex.self)
    
    init(delegate:AudioSamplingInstanceDelegate,
         engine: AVAudioEngine = AVAudioEngine(),
         audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.delegate = delegate
        self.engine = engine
        self.audioSession = audioSession
    }
    
    func sample() {
        
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        weak var weakSelf = self
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) {(buffer, time) in
            let channelData = buffer.floatChannelData![0]
            weakSelf?.performFFT(discreteSignal: Array(UnsafeBufferPointer(start:channelData, count: 4096)))
        }
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
    }
    
    func performFFT(discreteSignal:[Float]) {
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
                        
                        if let setup = fftSetUp {
                            setup.forward(input: forwardInput, output: &forwardOutput)
                        }
                        
                    }
                }
            }
        }
        self.computePowerDensity(realOutput: &forwardOutputReal, imaginaryOutput: &forwardOutputImag)
    }
    
    func computePowerDensity(realOutput:inout [Float], imaginaryOutput:inout [Float]){
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
        print("")
        delegate?.sampleProcessed(result: autospectrum)
    }
    
}


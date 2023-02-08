//
//  FFTPowerSpectrum.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 2/6/23.
//

import Foundation
import Accelerate

protocol PowerSpectrumCalculation {
    func execute(discreteSignal:[Float], _ completion:PowerSpectrumCompletion)
}

typealias PowerSpectrumCompletion = ((FrequencyResponse) -> Void)
class FFTPowerSpectrum: PowerSpectrumCalculation {
    let n: UInt
    var halfN: Int
    lazy var log2n = vDSP_Length(log2(Float(n)))
    
    lazy var fft = vDSP.FFT(log2n: log2n,
                            radix: .radix2,
                            ofType: DSPSplitComplex.self)
    var forwardInputReal: [Float]
    var forwardInputImag: [Float]
    var forwardOutputReal: [Float]
    var forwardOutputImag: [Float]
    init(n:UInt) {
        self.n = vDSP_Length(n)
        self.halfN = Int(n / 2)
        forwardInputReal = [Float](repeating: 0, count: halfN)
        forwardInputImag = [Float](repeating: 0, count: halfN)
        forwardOutputReal = [Float](repeating: 0, count: halfN)
        forwardOutputImag = [Float](repeating: 0, count: halfN)
    }
    
    func execute(discreteSignal:[Float], _ completion:PowerSpectrumCompletion) {
        
        var magnitudes = [Float](repeating: 0, count: halfN)
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
//                            vDSP.absolute(forwardOutput, result: &magnitudes)
//                            vDSP.convert(amplitude: magnitudes,
//                                         toDecibels: &magnitudes,
//                                         zeroReference: Float(n))
                        }
                        
                    }
                }
            }
        }
        var autoSpectrum = self.computePowerDensity(realOutput: &forwardOutputReal,
                                                    imaginaryOutput: &forwardOutputImag)
        
        completion(FrequencyResponse(autoSpectrum: autoSpectrum))
    }
    
    func computePowerDensity(realOutput:inout [Float], imaginaryOutput:inout [Float]) -> [Float] {
        var autospectrum = [Float](unsafeUninitializedCapacity: halfN) {
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
        vDSP.convert(amplitude: autospectrum,
                     toDecibels: &autospectrum,
                     zeroReference: Float(n))
        return autospectrum
    }
}

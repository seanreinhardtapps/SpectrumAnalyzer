//
//  FFTPowerSpectrum.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 2/6/23.
//

import Foundation
import Accelerate

protocol PowerSpectrumCalculation {
    func execute(discreteSignal:[Float], sampleRate: Double) async -> FrequencyResponse
}

actor FFTPowerSpectrum: PowerSpectrumCalculation {
    let n: UInt
    var halfN: Int
    var log2n: UInt
    
    let fft: vDSP.FFT<DSPSplitComplex>?
    init(n:UInt) {
        self.n = vDSP_Length(n)
        self.halfN = Int(n / 2)
        log2n = vDSP_Length(log2(Float(n)))
        fft = vDSP.FFT(log2n: log2n,
                       radix: .radix2,
                       ofType: DSPSplitComplex.self)
    }
    
    func execute(discreteSignal:[Float], sampleRate: Double) async -> FrequencyResponse {
        return await withCheckedContinuation { continuation in
            var autoSpectrum = [Float](repeating: 0, count: halfN)
            var forwardInputReal = [Float](repeating: 0, count: halfN)
            var forwardInputImag = [Float](repeating: 0, count: halfN)
            var forwardOutputReal = [Float](repeating: 0, count: halfN)
            var forwardOutputImag = [Float](repeating: 0, count: halfN)
            forwardInputReal.withUnsafeMutableBufferPointer { forwardInputRealPtr in
                forwardInputImag.withUnsafeMutableBufferPointer { forwardInputImagPtr in
                    forwardOutputReal.withUnsafeMutableBufferPointer { forwardOutputRealPtr in
                        forwardOutputImag.withUnsafeMutableBufferPointer { forwardOutputImagPtr in
                            
                            guard let forwardInputRealAddr = forwardInputRealPtr.baseAddress,
                                  let forwardInputImagAddr = forwardInputImagPtr.baseAddress,
                                  let forwardOutputRealAddr = forwardOutputRealPtr.baseAddress,
                                  let forwardOutputImagAddr = forwardOutputImagPtr.baseAddress else {
                                return
                            }
                            // Create a `DSPSplitComplex` to contain the signal.
                            var forwardInput = DSPSplitComplex(realp: forwardInputRealAddr,
                                                               imagp: forwardInputImagAddr)

                            // Convert the real values in `signal` to complex numbers.
                            discreteSignal.withUnsafeBytes {
                                vDSP.convert(interleavedComplexVector: [DSPComplex]($0.bindMemory(to: DSPComplex.self)),
                                             toSplitComplexVector: &forwardInput)
                            }

                            // Create a `DSPSplitComplex` to receive the FFT result.
                            var forwardOutput = DSPSplitComplex(realp: forwardOutputRealAddr,
                                                                imagp: forwardOutputImagAddr)

                            if let fft = self.fft {
                                fft.forward(input: forwardInput, output: &forwardOutput)
                                vDSP.absolute(forwardOutput,
                                              result: &autoSpectrum)
                                vDSP.convert(amplitude: autoSpectrum,
                                             toDecibels: &autoSpectrum,
                                             zeroReference: Float(halfN))
                            }

                        }
                    }
                }
            }

            let bucketSize = Double(sampleRate / Double(self.n))
            let spectrum = FrequencyResponse(autoSpectrum: autoSpectrum, bucketSize: bucketSize)
            continuation.resume(returning:spectrum)
        }
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

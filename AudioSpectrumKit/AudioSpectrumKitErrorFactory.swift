//
//  AudioSpectrumKitErrorFactory.swift
//  AudioSpectrumKit
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation

public let AudioSpectrumErrorDomain:String = "com.audioSpectrumFactory.error"
public enum AudioSpectrumErrorCode: Int {
    case permissionDenied
    case permissionKeyInvalid
}

internal class AudioSpectrumKitErrorFactory {
    static func permissionError() -> Error {
        return NSError(domain:AudioSpectrumErrorDomain,
                       code:AudioSpectrumErrorCode.permissionDenied.rawValue,
                       userInfo: [ NSLocalizedDescriptionKey: "Recording Permission not granted"])
    }
    
    static func plistError() -> Error {
        return NSError(domain:AudioSpectrumErrorDomain,
                       code:AudioSpectrumErrorCode.permissionKeyInvalid.rawValue,
                       userInfo: [ NSLocalizedDescriptionKey: "Recording Permission Plist Key missing"])
    }
}

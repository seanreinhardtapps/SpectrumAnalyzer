//
//  Frequency.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation

public struct Frequency: Codable, Identifiable {
    public var id:String
    public var hz: Int
    public var db: Float
    
    init(index:Int, db:Float) {
        self.db = db
        self.hz = index
        if db > 1000 {
            self.id = "\(self.hz / 1000)kHz"
        } else {
            self.id = "\(self.hz)Hz"
        }
    }
}

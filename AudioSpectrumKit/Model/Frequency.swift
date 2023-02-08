//
//  Frequency.swift
//  SpectrumAnalyzer
//
//  Created by Sean Reinhardt on 6/12/22.
//

import Foundation

public struct Frequency: Codable, Identifiable {
    public var id:String
    public var hz: Float
    public var db: Float
    
    init(index:Int, db:Float, bucketSize:Double) {
        self.db = db
        self.hz = Float(Double(index) * bucketSize)
        if db > 1000 {
            self.id = String(format: "%.1fkHz", (self.hz / 1000))
        } else {
            self.id = String(format: "%.1fHz", self.hz)
        }
    }
}

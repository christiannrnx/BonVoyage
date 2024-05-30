//
//  HeartRateModel.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import Foundation

public class HeartRateModel: Encodable {
    public var hearRate: Double
    public var time: String
    init(hearRate: Double, time: String) {
        self.hearRate = hearRate
        self.time = time
    }
}

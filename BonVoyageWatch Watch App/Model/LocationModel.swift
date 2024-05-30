//
//  LocationModel.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import Foundation

public class LocationModel: Encodable {
    
    public var latitude: Double
    
    public var longitude: Double
    
    public var altitude: Double
    
    public var speed: Double
    
    public var heartRate: Double
    
    public var time: String
    
    init(latitude: Double, longitude: Double, altitude: Double, speed: Double, hearRate: Double, time: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.heartRate = hearRate
        self.time = time
    }

}

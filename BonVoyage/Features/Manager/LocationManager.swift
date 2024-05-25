//
//  LocationManager.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // Variable that manages the location, start and stop delivery of location related events
    private var locationManager: CLLocationManager?
    
    @Published var region: MKCoordinateRegion?
    @Published var location: CLLocation??
    @Published var error: Error?
    
    override init() {
        super.init()
        requestLocation()
    }
    
    // Function that requests the user to access their location
    func requestLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Best location accuracy if possible
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Function that determines when to request location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
                break
            default:
                locationManager?.requestLocation()
                break
        }
    }
    
    // Function to update the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // We work with the last location
        if let location = locations.last {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            self.region = region
            self.location = location
        }
    }
    
    // Function to handle errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    
    
    
    
}

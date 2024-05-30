//
//  LocationManager.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import MapKit
import SwiftUI
import WatchConnectivity
import Foundation
import CoreLocation
import WatchKit
import Combine



struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

public class LocationManager: NSObject, CLLocationManagerDelegate {
    @Published public var carDistance: Double?
    
    @Published public var userLocation : CLLocation?
        
    public var locationManager: CLLocationManager?
        
    @Published public var authorizationForLocation: Bool = false
        
    override init() {
        super.init()
        checkIfLocationServicesIsEnabled()
    }
    
    public func checkIfLocationServicesIsEnabled(){
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        print("[watch-location-user] checkLocationAuthorization")
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            stopLocationUpdates()
            authorizationForLocation = false
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            startLocationUpdates()
            authorizationForLocation = true
            print("USER LOCATION IS RESTRICTED")
        case .denied:
            stopLocationUpdates()
            authorizationForLocation = false
            print("DENY PLEASE ALLOW THE USER LOCATION")
        case .authorizedWhenInUse, .authorizedAlways:
            print("[watch-location-user] Accepted")
            authorizationForLocation = true
            break
        @unknown default:
            break
        }
    }
    
    public func startLocationUpdates() {
        guard let locationManager = locationManager else { return }
        print("[watch-location-user] Location Updates Started")
        locationManager.startUpdatingLocation()
        
    }
    
    public func stopLocationUpdates() {
        guard let locationManager = locationManager else { return }
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            userLocation = lastLocation
            print("[watch-location-user] UserLocationUpdated \(lastLocation)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[watch-location] Location update failed: \(error.localizedDescription)")
    }
    
    func distanceFromUserLocation(to location: CLLocation) -> CLLocationDistance? {
        guard let locationManager = locationManager else { return -1 }
        
        guard let userLocation = locationManager.location else {
            return nil
        }

        let targetLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        return userLocation.distance(from: targetLocation)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization status changed to \(manager)")
        // IT IS CALLED WHEN THE LOCATION MANAGER IS INITIALIZED
        checkLocationAuthorization()
    }

}

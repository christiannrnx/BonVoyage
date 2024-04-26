//
//  MapViewModel.swift
//  BonVoyage
//
//  Created by Christian Romero on 25/4/24.
//

import Foundation
import Observation
import MapKit
import SwiftUI

// Enum to switch between map styles
enum MyMapStyle: Int {
    
    case standard = 0
    case imagery
    case hybrid
    
    // Transform enum case to MapKit class that represents the map style
    func toMapStyle() -> MapStyle {
        switch self {
            case .standard: return .standard
            case .imagery: return .imagery
            case .hybrid: return .hybrid
        }
    }
    
    // Switch map style
    func toogle() -> MyMapStyle {
        switch self {
            case .standard: return .imagery
            case .imagery: return .hybrid
            case .hybrid: return .standard
        }
    }
    
}


@Observable class MapViewModel {
    
    // Map attributes
    var cameraPosition: MapCameraPosition
    var location: CLLocation?
    var region: MKCoordinateRegion
    var mapSelection: MKMapItem?
    var mapStyle: MyMapStyle = .standard
    var isLoading: Bool = false
    var viewingRegion: MKCoordinateRegion?
    
    init(location: CLLocation?, region: MKCoordinateRegion) {
        self.cameraPosition = .region(region)
        self.location = location
        self.region = region
    }
    
    
}

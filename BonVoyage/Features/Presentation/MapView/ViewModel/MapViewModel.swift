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
    var routeDisplaying: Bool = false
    var lookAroundScene: MKLookAroundScene?
    var route: MKRoute?
    var destinationCoordinate: CLLocationCoordinate2D?
    // Search Properties
    var searchText: String = ""
    var showSearch: Bool = false
    var searchResults: [MKMapItem] = []
    
    
    init(location: CLLocation?, region: MKCoordinateRegion) {
        self.cameraPosition = .region(region)
        self.location = location
        self.region = region
    }
}


extension MapViewModel {
    
    // Feature look around preview
    func fetchLookAroundPreview(coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        lookAroundScene = nil
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        lookAroundScene = try? await request.scene
    }
    
    //Feature calculate routes
    func calculateRoute(from source: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D?) async {
        
        guard let source, let destination else { return }
        isLoading = true
        
        // Request MapKit for the route
        let request = MKDirections.Request()
        request.source = .init(placemark: .init(coordinate: source))
        request.destination = .init(placemark: .init(coordinate: destination))
        request.transportType = .automobile
        
        let result = try? await MKDirections(request: request).calculate()
        route = result?.routes.first
        mapSelection = request.destination
        destinationCoordinate = destination
        
        withAnimation(.snappy){
            routeDisplaying = true
            isLoading = false
        }
    }
    
    // Function that resets the route data
    func resetRoute() {
        routeDisplaying = false
        route = nil
        destinationCoordinate = nil
    }
    
    // Function to search a place with the searchBar
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
}

//
//  MapView.swift
//  BonVoyage
//
//  Created by Christian Romero on 25/4/24.
//

import SwiftUI
import Observation
import MapKit

struct MapView: View {
    
    @Bindable var viewModel: MapViewModel
    @State var showErrorAlert = false
    @State var lookAroundViewIsExpanded: Bool = false
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack{
            mapView
            
            if viewModel.lookAroundScene != nil {
                lookAroundPreviewView
            }
            
        }.alert(isPresented: $showErrorAlert){
            Alert(title: Text("Important message"),
                  message: Text("Unexpected error is happening"),
                  dismissButton: .default(Text("Got it!")))
        }
        
    }
    
    
    var mapView: some View {
        
        NavigationStack {
            
            Map(position: $viewModel.cameraPosition, selection: $viewModel.mapSelection){
                // User location point
                UserAnnotation()
                
                if let route = viewModel.route {
                    if let coordinate = viewModel.destinationCoordinate {
                        Annotation("Destino", coordinate: coordinate) {
                            AnimatedMarker(systemName: "mappin.circle.fill", imageColor: .red, backgroundColor: .clear)
                        }.annotationTitles(.hidden)
                    }
                    
                    MapPolyline(route.polyline)
                        .stroke(.red, lineWidth: 8)
                }
                
                if viewModel.lookAroundScene != nil {
                    if let coordinate = viewModel.viewingRegion?.center {
                        Annotation("Marcador", coordinate: coordinate) {
                            AnimatedMarker(systemName: "binoculars.fill", imageColor: .blue, backgroundColor: .clear)
                        }.annotationTitles(.hidden)
                    }
                }
                
                // Display search results as markers
                ForEach(viewModel.searchResults, id: \.self) { mapItem in
                    let placemark = mapItem.placemark
                    Marker(placemark.name ?? "Búsqueda", coordinate: placemark.coordinate)
                }
                
            }.mapStyle(viewModel.mapStyle.toMapStyle())
                .onMapCameraChange { ctx in
                    // Update viewing position while navigating
                    viewModel.viewingRegion = ctx.region
                }
                .overlay(alignment: .topTrailing) {
                    // Top Trailing Buttons
                    topTrailingOverlayView
                }
                .overlay(alignment: .bottomTrailing) {
                    // Bottom Trailing Buttons
                    bottomTrailingOverlayView
                }
                .overlay(alignment: .bottomLeading) {
                    // Bottom Leading Buttons
                    if !viewModel.routeDisplaying {
                        bottomLeadingOverlayView
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if viewModel.routeDisplaying {
                        endRouteButtonView
                    }
                }
                .onTapGesture {
                    if !viewModel.routeDisplaying {
                        Task {
                            await viewModel.calculateRoute(from: viewModel.location?.coordinate, to: viewModel.viewingRegion?.center)
                        }
                    }
                }
                .navigationTitle("Map")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, isPresented: $viewModel.showSearch)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .onSubmit(of: .search) {
            Task {
                // Search places
                guard !viewModel.searchText.isEmpty else { return }
                await viewModel.searchPlaces()
            }
        }
        .onChange(of: viewModel.showSearch, initial: false) {
            if !viewModel.showSearch {
                // Clear search results
                viewModel.searchResults.removeAll(keepingCapacity: false)
            }
        }
        
        
    }
    
    
}


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
        
        Map(position: $viewModel.cameraPosition, selection: $viewModel.mapSelection){
            // User location point
            UserAnnotation()
            
            if viewModel.lookAroundScene != nil {
                if let coordinate = viewModel.viewingRegion?.center {
                    Annotation("Marker", coordinate: coordinate) {
                        AnimatedMarker(systemName: "mappin.circle.fill", imageColor: .red, backgroundColor: .clear)
                    }
                }
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
    }
   
    
    
}


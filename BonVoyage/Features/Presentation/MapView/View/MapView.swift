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
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack{
            Map(position: $viewModel.cameraPosition, selection: $viewModel.mapSelection){
                UserAnnotation()
            }.mapStyle(viewModel.mapStyle.toMapStyle())
                .onMapCameraChange { ctx in
                    viewModel.viewingRegion = ctx.region
                }
                .overlay(alignment: .topTrailing) {
                    topTrailingOverlayView
                }
            
        }
        
    }
}


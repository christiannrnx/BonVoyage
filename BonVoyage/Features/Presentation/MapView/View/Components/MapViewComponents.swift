//
//  MapViewComponents.swift
//  BonVoyage
//
//  Created by Christian Romero on 26/4/24.
//

import SwiftUI

extension MapView {
    
    var topTrailingOverlayView: some View {
        
        VStack(spacing: -5){
            IconView(systemName: "map.fill")
                .onTapGesture {
                    self.viewModel.mapStyle = viewModel.mapStyle.toogle()
                }
        }
        
    }
    
}

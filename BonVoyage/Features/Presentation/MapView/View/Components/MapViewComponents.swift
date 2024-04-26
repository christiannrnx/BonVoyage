//
//  MapViewComponents.swift
//  BonVoyage
//
//  Created by Christian Romero on 26/4/24.
//

import SwiftUI

// Top Trailing Buttons
extension MapView {
    
    var topTrailingOverlayView: some View {
        
        VStack(spacing: -5){
            
            // Switch map style button
            IconView(systemName: "map.fill")
                .onTapGesture {
                    self.viewModel.mapStyle = viewModel.mapStyle.toogle()
                }
            
            // Return to user location button
            if viewModel.isLoading {
                ProgressView()
                    .font(.title3)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 44, height: 46)
                            .foregroundColor(.init(.systemBackground))
                    )
                    .padding()
            } else {
                IconView(systemName: "location.fill")
                    .onTapGesture {
                        withAnimation {
                            viewModel.cameraPosition = .region(viewModel.region)
                        }
                    }
            }
        }
    }
}

// Bottom Trailing Button
extension MapView {
    
    var bottomTrailingOverlayView: some View {
        
        HStack(spacing: -10){
            IconView(systemName: "sun.min.fill", imageColor: .yellow)
                .offset(x:-10)
            Text("14º")
                .foregroundColor(.init(.gray))
                .font(.title3)
                .offset(x:-13)
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 62, height: 46)
                .foregroundColor(.init(.systemBackground))
        ).offset(y:-100)
    }
    
}

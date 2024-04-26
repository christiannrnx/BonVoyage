//
//  MapViewComponents.swift
//  BonVoyage
//
//  Created by Christian Romero on 26/4/24.
//

import SwiftUI
import MapKit

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


// Bottom Leading Button
extension MapView {
    
    var bottomLeadingOverlayView: some View {
        
        IconView(systemName: "binoculars.fill")
            .frame(width: 62, height: 46)
            .offset(y:-100)
            .onTapGesture {
                Task {
                    guard let coordinate = viewModel.viewingRegion?.center else {
                        showErrorAlert = true
                        return
                    }
                    await viewModel.fetchLookAroundPreview(coordinate: coordinate)
                    viewModel.isLoading = false
                }
            }
    }
    
}


// Look Around Preview
extension MapView {
    
    var lookAroundPreviewView: some View {
        
        VStack {
            
            LookAroundPreview(scene: $viewModel.lookAroundScene)
                .frame(height: lookAroundViewIsExpanded ? UIScreen.main.bounds.height - 32 : 300)
                .animation(.easeInOut, value: viewModel.lookAroundScene)
                .overlay(alignment: .topTrailing, content: {
                    VStack {
                        IconView(systemName: "xmark.circle.fill")
                            .frame(width: 62, height: 46)
                            .onTapGesture {
                                Task {
                                    viewModel.lookAroundScene = nil
                                    lookAroundViewIsExpanded = false
                                }
                            }
                        IconView(systemName: lookAroundViewIsExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.backward.and.arrow.down.forward")
                            .frame(width: 62, height: 46)
                            .onTapGesture {
                                Task {
                                    lookAroundViewIsExpanded.toggle()
                                }
                            }
                    }.padding(.vertical)
                }).padding(.horizontal, 4)
            Spacer()
            
        }

    }

    
}

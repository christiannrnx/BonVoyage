//
//  MapViewComponents.swift
//  BonVoyage
//
//  Created by Christian Romero
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
            
            NavigationLink(destination: destinationView()){
                // User Profile
                IconView(systemName: "person.crop.circle.fill")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didLogIn"))) { _ in
            self.viewModel.isLoggedIn = AuthenticationManager.shared.isLoggedIn()
        }
    }
    @ViewBuilder
    func destinationView() -> some View {
        if viewModel.isLoggedIn {
            ProfileView()
        } else {
            SignInViewControllerRepresentable()
        }
    }
}

// Representable for SignInViewController to use in SwiftUI
struct SignInViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

// Bottom Trailing Button
extension MapView {
    
    var bottomTrailingOverlayView: some View {
        
        HStack(spacing: -10){
            IconView(systemName: "heart.fill", imageColor: .red)
                .offset(x:-10)
            Text("\(Int(healthManager.userHeartRate))")
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
                    viewModel.lookAroundBinoculars = true
                    await viewModel.fetchLookAroundPreview(coordinate: coordinate)
                    viewModel.isLoading = false
                }
            }
    }
    
}


// End Route Button
extension MapView {
    var endRouteButtonView: some View {
        Button("Finalizar") {
            withAnimation(.snappy){
                viewModel.resetRoute()
                if let coordinate = viewModel.mapSelection?.placemark.coordinate {
                    viewModel.cameraPosition = .region(.init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .padding(.vertical, 12)
        .background(.red.gradient, in: .rect(cornerRadius: 15))
        .padding()
        .background(.ultraThinMaterial)
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
                                    viewModel.lookAroundBinoculars = false
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


// Place Details
extension MapView {
    
    var placeDetailsView: some View {
        
        VStack(spacing: 15) {
            HStack {
                
                VStack (alignment: .leading) {
                    Text(viewModel.mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(viewModel.mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                
                Spacer()
                
                Button {
                    viewModel.showDetails.toggle()
                    viewModel.mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }

            }
            ZStack {
                if viewModel.lookAroundScene == nil {
                    // Empty Look Around Preview
                    ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
                } else {
                    LookAroundPreview(scene: $viewModel.lookAroundScene)
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 15))
            
            // Calculate Route Button
            Button("Iniciar Ruta") {
                Task {
                    await viewModel.calculateRoute(from: viewModel.location?.coordinate, to: viewModel.mapSelection?.placemark.coordinate)
                    viewModel.showDetails = false
                    
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.red.gradient, in: .rect(cornerRadius: 15))
            
        }
        .padding(15)
    }
    
}

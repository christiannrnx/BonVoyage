//
//  HomeView.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        
        if let location = locationManager.location, let region = locationManager.region {
            MapView(viewModel: MapViewModel(location: location, region: region))
        } else {
            ProgressView()
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

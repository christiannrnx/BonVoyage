//
//  HomeView.swift
//  BonVoyage
//
//  Created by Christian Romero on 25/4/24.
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

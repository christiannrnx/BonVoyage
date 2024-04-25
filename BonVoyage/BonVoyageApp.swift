//
//  BonVoyageApp.swift
//  BonVoyage
//
//  Created by Christian Romero on 15/4/24.
//

import SwiftUI

@main
struct BonVoyageApp: App {
    
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}

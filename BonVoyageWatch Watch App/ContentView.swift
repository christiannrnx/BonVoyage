//
//  ContentView.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import Foundation
import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        
        ZStack {
            // Map Background
            MapView()
                .edgesIgnoringSafeArea(.all) // Asegura que el mapa ocupe toda la pantalla
            
        }
        .overlay(alignment: .center){
    
        }
        .overlay(alignment: .bottom){
            // Contenido principal
            VStack(alignment: .center) {
                Button("Iniciar Ruta") {
                    vm.startDriveWorkout()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}

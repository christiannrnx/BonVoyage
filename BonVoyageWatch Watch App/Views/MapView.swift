//
//  MapView.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import SwiftUI
import Observation
import MapKit

struct MapView: View {
    
    @State var showErrorAlert = false
    
    var body: some View {
        
        ZStack{
            mapView
            
        }.alert(isPresented: $showErrorAlert){
            Alert(title: Text("Alerta"),
                  message: Text("Error inesperado"),
                  dismissButton: .default(Text("De acuerdo")))
        }
        
    }
    
    
    var mapView: some View {
        
        NavigationStack {
            
            Map(){
                // User location point
                UserAnnotation()
            }
        }
        
    }
    
}

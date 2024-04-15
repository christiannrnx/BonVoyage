//
//  ContentView.swift
//  BonVoyage
//
//  Created by Christian Romero on 15/4/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        MapView()
                    .edgesIgnoringSafeArea(.all)

    }
}

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        //  Actualizaciones en el mapa si es necesario
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

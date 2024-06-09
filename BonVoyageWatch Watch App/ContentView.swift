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
            // Contenido principal
            VStack(alignment: .center) {
                Button("Notificación") {
                    let content = UNMutableNotificationContent()
                    content.title = "Alerta de cansancio!"
                    content.subtitle = "Deberías parar a despejarte"
                    content.sound = .default
                    content.categoryIdentifier = "tiredAlert"
                    
                    let action = UNNotificationAction(identifier: "done", title: "Done", options: .foreground)
                    let category = UNNotificationCategory(identifier: "tiredAlert", actions: [action], intentIdentifiers: [], options: [])
                    
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                    let request = UNNotificationRequest(identifier: "sleep", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else{
                            print("Notification created")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
            }
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

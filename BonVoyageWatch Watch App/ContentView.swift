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
        .overlay(alignment: .bottom){
            // Contenido principal
            VStack(alignment: .center) {
                Button("Notificción") {
                    let content = UNMutableNotificationContent()
                    content.title = "Alerta de estrés!"
                    content.subtitle = "Deberías parar a descansar"
                    content.sound = .defaultCritical
                    content.categoryIdentifier = "myCategory"
                    
                    let action = UNNotificationAction(identifier: "done", title: "Done", options: .foreground)
                    let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
                    
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                    let request = UNNotificationRequest(identifier: "heart", content: content, trigger: trigger)
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

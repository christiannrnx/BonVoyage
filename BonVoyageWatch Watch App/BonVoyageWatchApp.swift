//
//  BonVoyageWatchApp.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import SwiftUI

@main
struct BonVoyageWatch_Watch_AppApp: App {
    
    @StateObject private var viewModel = ViewModel()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView{
                if viewModel.workout == .started{
                    WorkoutView()
                }else if viewModel.workout == .finished{
                    ContentView()
                }
            }.environmentObject(viewModel)
        }
        WKNotificationScene(controller: NotificationController.self, category: "stressAlert")
    }
}


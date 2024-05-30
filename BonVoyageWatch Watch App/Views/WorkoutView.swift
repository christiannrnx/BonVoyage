//
//  RouteView.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import SwiftUI
import WatchKit

struct WorkoutView: View {
    
    @EnvironmentObject var vm: ViewModel

    @State var selectedTag: Int = 1
    
    @State var timeElapsed: Int = 0
    @State var timeElapsedString: String = "00:00:00"
    
    @State private var nowPlayingInfo: [String: Any]? = nil
    
    @State var currentDate = Date.now
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $selectedTag){
            controllView().tag(0)
            workoutView().tag(1)
            NowPlayingView().tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .navigationBarHidden(true)
            
    }
    
    func controllView() -> some View{
        VStack{
            HStack{
                VStack{
                    Button {
                        vm.endWorkout()
                    }
                    label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.red).opacity(0.8)
                
                    Text("Finalizar")
                }
                VStack{
                    Button {
                        withAnimation(){
                            if vm.workout == .paused{
                                vm.resumeWorkout()
                            }else{
                                vm.pauseWorkout()
                            }
                        }
                    }
                    label: {
                        if vm.workout == .paused{
                            Image(systemName: "arrow.clockwise")
                        }else{
                            Image(systemName: "pause")
                        }
                    }
                    .tint(.yellow).opacity(0.8)
                    if vm.workout == .paused{
                        Text("Continuar")
                    }else{
                        Text("Pausar")
                    }
                }
            }

        }
    }
    
    func workoutView() -> some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "car.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
                Spacer()
            }
            Text("\(timeElapsedString)")
                .onReceive(timer) { input in
                    if vm.workout == .started{
                        timeElapsed += 1
                        formattedTimeFromSeconds(timeElapsed)
                    }
                }.foregroundColor(.yellow)
                .font(.title2)
            HStack{
                Text("\(Int(vm.workoutManager.heartRate)) BPM")
                    .font(.title2)
                Image(systemName: "heart.fill").foregroundColor(.red)
            }
            Text("\(Int(vm.locationManager.userLocation?.speed.magnitude ?? 0)) Km/h")
                .font(.title2)
            Text("\(Int(vm.locationManager.userLocation?.altitude.magnitude ?? 0)) M")
                .font(.title2)
            
            
            
            
            
        }.padding(.horizontal, 30)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func formattedTimeFromSeconds(_ seconds: Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        let formattedHours = String(format: "%02d", hours)
        let formattedMinutes = String(format: "%02d", minutes)
        let formattedSeconds = String(format: "%02d", seconds)
        
        timeElapsedString =  "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
    }
    
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView().environmentObject(ViewModel())
    }
}

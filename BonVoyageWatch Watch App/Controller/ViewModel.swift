//
//  ViewModel.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero
//

import Foundation
import CoreLocation
import Combine
import UserNotifications


public class ViewModel: ObservableObject{
    
    @Published public var locationManager: LocationManager
    
    @Published public var workoutManager: WorkoutManager
    
    @Published public var connectionProvider: ConnectionProvider
    
    @Published public var paused: Bool = true
    
    
    private var HeartRateCancellable: AnyCancellable?
    private var LocationCancellable: AnyCancellable?
    private var HearRateWorkoutCancellable: AnyCancellable?
    
    private var counter: Int
    
    init(){
        locationManager = LocationManager()
        workoutManager = WorkoutManager()
        connectionProvider = ConnectionProvider(watchConnectivityManager: WatchConnectivityManager(sessionDelegate: SessionDelegate()))
        counter = Int(UserDefaults.standard.string(forKey: "counter") ?? "0") ?? 0
        print("[workout] COUNTER: ", counter)
        workoutManager.requestAuthorization()
    }
    
    @Published var workout: workoutState = .finished
    
    var coordinatesVector: [LocationModel] = []
        
    var heartRateVector: [HeartRateModel] = []
    
    // WORKOUT
    
    var workoutName: String = String(Date().formatted(date: .complete, time: .shortened))
    
    var dispathWorkSendToBackend: DispatchWorkItem?
    var dispathWorkSendToFinalToBackend: DispatchWorkItem?
    
    
    func startDriveWorkout(){
        requestNotifications()
        workout = .started
        recordData()
        workoutManager.startWorkout(workoutType: .cycling)
        workoutName = String(Date().formatted(date: .complete, time: .shortened))
        locationManager.startLocationUpdates()
    }
    
    func recordData(){
        LocationCancellable = locationManager.$userLocation.sink { location in
            if self.workout == .started{
                print("[workout] [locationUpdate] updated")
                if let location = location {
                    print("[workout] [locationUpdate] location Exists")
                    let currentDate = Date()
                    let unixTimestamp = String(Int(currentDate.timeIntervalSince1970))
                    self.coordinatesVector.append( LocationModel(latitude: location.coordinate.latitude.magnitude, longitude: location.coordinate.longitude.magnitude, altitude: location.altitude.magnitude, speed: location.speed.magnitude * 14.4, hearRate: self.workoutManager.heartRate, time: unixTimestamp) )
                }else{
                    print("[workout] [locationUpdate] location Failed")
                }
            }
            
        }
        HearRateWorkoutCancellable = workoutManager.$heartRate.sink { heartRate in
            if self.workout == .started{
                let currentDate = Date()
                let unixTimestamp = String(Int(currentDate.timeIntervalSince1970))
                self.heartRateVector.append(HeartRateModel(hearRate: heartRate, time: unixTimestamp))
            }
        }
    }

    func endWorkout(){
        workout = .finished
        counter += 1
        dispathWorkSendToBackend?.cancel()
        workoutManager.endWorkout()
    }
    
    
    func pauseWorkout(){
        workout = .paused
        dispathWorkSendToBackend?.cancel()
        workoutManager.pause()
    }
    
    func resumeWorkout(){
        workout = .started
        workoutManager.resume()
    }
    
    func requestNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (success,error) in
            if success {
                print("Notifications Allowed")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}

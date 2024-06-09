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


public class ViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate{
    
    @Published public var locationManager: LocationManager
    @Published public var workoutManager: WorkoutManager
    @Published public var connectionProvider: ConnectionProvider
    @Published public var paused: Bool = true
    
    private var HeartRateCancellable: AnyCancellable?
    private var LocationCancellable: AnyCancellable?
    private var HearRateWorkoutCancellable: AnyCancellable?
    
    private var counter: Int
    
    private var HRVmean: Double = 0
    private var HRVstd: Double = 0
    private var HRmean: Double = 0
    private var HRstd: Double = 0
    private var RestingHRmean: Double = 0
    private var RestingHRstd: Double = 0
    
    
    // Calculate alert thresholds
    private var HRVstressThreshold: Double {
        return HRVmean - (1.5 * HRVstd)
    }
    
    private var HRstressThreshold: Double {
        return HRmean + (1.5 * HRstd)
    }
    
    private var HRsleepThreshold: Double {
        return RestingHRmean - (1.5 * RestingHRstd)
    }
    
    // Variables to control the time between notifications
    private var lastNotificationDate: Date?
    private let notificationCooldown: TimeInterval = 300 // 5 minutes
    
    override init(){
        self.locationManager = LocationManager()
        self.workoutManager = WorkoutManager()
        self.connectionProvider = ConnectionProvider(watchConnectivityManager: WatchConnectivityManager(sessionDelegate: SessionDelegate()))
        self.counter = Int(UserDefaults.standard.string(forKey: "counter") ?? "0") ?? 0
        print("[workout] COUNTER: ", counter)
        
        super.init()
        workoutManager.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
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
                    self.coordinatesVector.append( LocationModel(latitude: location.coordinate.latitude.magnitude, longitude: location.coordinate.longitude.magnitude, altitude: location.altitude.magnitude, speed: location.speed.magnitude * 3.6 * 4.0 , hearRate: self.workoutManager.heartRate, time: unixTimestamp) )
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
                self.checkHeartRateThresholds(heartRate: heartRate)
            }
        }
        self.HRmean = self.workoutManager.averageHeartRate
        print("HRMEAN \(self.HRmean)")
        print("averageHeartRate \(self.workoutManager.averageHeartRate)")
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
    
    // Request permission for notifications
    func requestNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (success,error) in
            if success {
                print("Notifications Allowed")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound])
        }
    
    // Check alert thresholds
    private func checkHeartRateThresholds(heartRate: Double) {
        print("CHECK THRESHOLDS")
        let now = Date()
        if let lastNotificationDate = lastNotificationDate, now.timeIntervalSince(lastNotificationDate) < notificationCooldown {
            print("WAITING FOR NOTIFICATION")
            return // Skip sending the notification if we're within the cooldown period
        }
        
        print("HeartRate \(heartRate), StressThreshold \(HRstressThreshold), SleepThreshold \(HRsleepThreshold)")
        if heartRate > HRstressThreshold {
            print("HeartRate \(heartRate) > StressThreshold \(HRstressThreshold)")
            let content = UNMutableNotificationContent()
            content.title = "Alerta de estrés!"
            content.subtitle = "Deberías parar a descansar"
            content.sound = .default
            content.categoryIdentifier = "stressAlert"
            
            let action = UNNotificationAction(identifier: "done", title: "Done", options: .foreground)
            let category = UNNotificationCategory(identifier: "stressAlert", actions: [action], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "heart", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    print("Stress notification created")
                    self.lastNotificationDate = now
                }
            }
        } else if heartRate < HRsleepThreshold {
            print("HeartRate \(heartRate) < SleepThreshold \(HRsleepThreshold)")
            let content = UNMutableNotificationContent()
            content.title = "Alerta de estrés!"
            content.subtitle = "Deberías parar a descansar"
            content.sound = .default
            content.categoryIdentifier = "stressAlert"
            
            let action = UNNotificationAction(identifier: "done", title: "Done", options: .foreground)
            let category = UNNotificationCategory(identifier: "stressAlert", actions: [action], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            let request = UNNotificationRequest(identifier: "heart", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else{
                    print("Sleep notification created")
                    self.lastNotificationDate = now
                }
            }
        }
    }
    
}

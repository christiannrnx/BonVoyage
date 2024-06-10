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
    private var HRVstressThreshold: Double = 0
    private var HRstressThreshold: Double = 0
    private var HRsleepThreshold: Double = 0
    
    // Variables to control the time between notifications
    private var lastNotificationDate: Date?
    private let notificationCooldown: TimeInterval = 300 // 5 minutes
    
    private let dispatchGroup = DispatchGroup()
    
    override init(){
        self.locationManager = LocationManager()
        self.workoutManager = WorkoutManager()
        self.connectionProvider = ConnectionProvider(watchConnectivityManager: WatchConnectivityManager(sessionDelegate: SessionDelegate()))
        self.counter = Int(UserDefaults.standard.string(forKey: "counter") ?? "0") ?? 0
        print("[workout] COUNTER: ", counter)
        
        super.init()
        workoutManager.requestAuthorization()
        UNUserNotificationCenter.current().delegate = self
        dispatchGroup.enter()
        workoutManager.fetchHeartRate {
            self.HRmean = self.workoutManager.userHeartRate
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        workoutManager.fetchRestingHeartRate {
            self.RestingHRmean = self.workoutManager.userRestingHeartRate
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        workoutManager.fetchHeartRateVariability {
            self.HRVmean = self.workoutManager.userHeartRateVariability
            self.dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.HRVstd = self.calculateStandardDeviation(values: self.generateSimulatedData(mean: self.HRVmean, count: 10))
            self.HRstd = self.calculateStandardDeviation(values: self.generateSimulatedData(mean: self.HRmean, count: 10))
            self.RestingHRstd = self.calculateStandardDeviation(values: self.generateSimulatedData(mean: self.RestingHRmean, count: 10))
            print("HR mean \(self.HRmean)")
            print("HRV mean \(self.HRVmean)")
            print("RestHR mean \(self.RestingHRmean)")
            print("HR std \(self.HRstd)")
            print("HRV std \(self.HRVstd)")
            print("RestHR std \(self.RestingHRstd)")
            self.HRsleepThreshold = self.calculateHRsleepThreshold(restinghrmean: self.RestingHRmean, restinghrstd: self.RestingHRstd)
            self.HRstressThreshold = self.calculateHRstressThreshold(hrmean: self.HRmean, hrstd: self.HRstd)
            self.HRVstressThreshold = self.calculateHRVstressThreshold(hrvmean: self.HRVmean, hrvstd: self.HRVstd)
        }
    }
    
    // Calculate alert thresholds
    private func calculateHRVstressThreshold(hrvmean: Double, hrvstd: Double) -> Double {
        return hrvmean - (1.5 * hrvstd)
    }
    
    private func calculateHRstressThreshold(hrmean: Double, hrstd: Double) -> Double {
        return hrmean + (5.0 * hrstd)
    }
    
    private func calculateHRsleepThreshold(restinghrmean: Double, restinghrstd: Double) -> Double {
        return restinghrmean - (1.5 * restinghrstd)
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
                if heartRate != 0 {
                    self.checkHeartRateThresholds(heartRate: heartRate)
                }
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
                    print("Sleep notification created")
                    self.lastNotificationDate = now
                }
            }
        }
    }
    
    // Generate simulated data
    private func generateSimulatedData(mean: Double, count: Int) -> [Double] {
        var simulatedData = [Double]()
        for _ in 0..<count {
            let randomValue = Double.random(in: (mean - 5)...(mean + 5))
            simulatedData.append(randomValue)
        }
        return simulatedData
    }

    // Calculate std
    private func calculateStandardDeviation(values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        return sqrt(variance)
    }
    
}

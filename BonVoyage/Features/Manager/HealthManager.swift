//
//  HealthManager.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation
import HealthKit


class HealthManager: ObservableObject {

    let healthStore = HKHealthStore()
    
    init(){
        requestAuthorization()
        fetchHeartRate()
        fetchRestingHeartRate()
        fetchHeartRateVariability()
    }
    

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }


    // MARK: - Workout Metrics
    @Published var userAverageHeartRate: Double = 0
    @Published var userHeartRate: Double = 0
    @Published var userRestingHeartRate: Double = 0
    @Published var userHeartRateVariability: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    
    func fetchHeartRate() {
        print("Fetch Heart Rate")
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        print("Start Date\(String(describing: startDate))")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else{
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let heartRate = data.quantity.doubleValue(for: unit)
            print("Latest HR \(heartRate) BPM")
            self.userHeartRate = heartRate
            
        }
        healthStore.execute(query)
        
        
    }
    
    func fetchRestingHeartRate() {
        print("Fetch Resting Heart Rate")
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        print("Start Date\(String(describing: startDate))")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else{
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let restingHeartRate = data.quantity.doubleValue(for: unit)
            print("Latest Rest HR \(restingHeartRate) BPM")
            self.userRestingHeartRate = restingHeartRate
            
        }
        healthStore.execute(query)
        
    }
    
    func fetchHeartRateVariability() {
        print("Fetch Heart Rate Variability")
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        print("Start Date\(String(describing: startDate))")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else{
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "ms")
            let heartRateVariability = data.quantity.doubleValue(for: unit)
            print("Latest HRV \(heartRateVariability) ms")
            self.userHeartRateVariability = heartRateVariability
            
        }
        healthStore.execute(query)
        
    }

    

}


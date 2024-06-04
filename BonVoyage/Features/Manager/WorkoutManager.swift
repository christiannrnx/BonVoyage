//
//  WorkoutManager.swift
//  BonVoyage
//
//  Created by Christian Romero
//

import Foundation
import HealthKit


public class WorkoutManager: NSObject, ObservableObject {

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    

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
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }


    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var restingHeartRate: Double = 0
    @Published var heartRateVariability: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .restingHeartRate):
                let restHeartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.restingHeartRate = statistics.mostRecentQuantity()?.doubleValue(for: restHeartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN):
                let heartRateVar = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRateVariability = statistics.mostRecentQuantity()?.doubleValue(for: heartRateVar) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }

}


//
//  ViewModel.swift
//  BonVoyage
//
//  Created by Christian Romero on 15/4/24.
//

import Foundation
import HealthKit
import MapKit

final class ViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    private var observerQueries: [HKObserverQuery] = []
    
    func requestAccessToHealthData() {
        let readableTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        ]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readableTypes) { success, error in
            print("Request Authorization \(success.description)")
            if success {
                self.observeHealthData()
            }
        }
    }
    
    private func observeHealthData() {
        let sampleTypes: [HKSampleType] = [
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        ]
        
        for sampleType in sampleTypes {
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, errorOrNil) in
                if let error = errorOrNil {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                // TODO: Handle observed health data
            }
            observerQueries.append(query)
            healthStore.execute(query)
        }
    }
}


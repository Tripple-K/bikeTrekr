import HealthKit

struct HealthAssistant {
    static var shared = HealthAssistant()
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {

        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
            
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }
    
    func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.save(data, withCompletion: completion)
    }
    
    func getAuthorizationStatus() -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: HKQuantityType.workoutType())
    }
    
    func didAddSession(with session: Session) {
        guard let sample = processHealthSample(with: session) else { return }

        
        saveHealthData([sample]) { success, error in
            if let error = error {
                print("DataTypeTableViewController didAddNewData error:", error.localizedDescription)
            }
            if success {
                print("Successfully saved a new sample!", sample)
            } else {
                print("Error: Could not save new sample.", sample)
            }
        }
    }
    
    private func processHealthSample(with session: Session) -> HKWorkout? {
        let totalEnergyBurned = HKQuantity(unit: .jouleUnit(with: .kilo), doubleValue: session.distance)
        let distance = HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: session.distance)
        return HKWorkout(activityType: session.typeSession.activityType, start: session.date, end: .now, duration: TimeInterval(session.duration), totalEnergyBurned: totalEnergyBurned, totalDistance: distance, metadata: nil)
    }
}

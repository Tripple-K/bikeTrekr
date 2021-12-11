
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion()
    @Published var speed = CLLocationSpeed()
    @Published var distance: Double
    var speeds = [CLLocationSpeed]()
    var avgSpeed: CLLocationSpeed {
        return speeds.reduce(0,+)/Double(speeds.count)
    }
    private let manager = CLLocationManager()
    var locations: [CLLocationCoordinate2D]
    var tracking: Bool {
        didSet {
            if tracking {
                manager.allowsBackgroundLocationUpdates = true
                manager.startMonitoringSignificantLocationChanges()
            } else {
                manager.allowsBackgroundLocationUpdates = false
                manager.stopMonitoringSignificantLocationChanges()
            }
        }
    }
    var finished: Bool
    var paused: Bool
    
    override init() {
        locations = []
        tracking = false
        finished = false
        paused = false
        distance = 0.0
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        speed = manager.location?.speed ?? 0
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        speeds.append(contentsOf: locations.map{$0.speed})
        
        locations.last.map {
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            region = MKCoordinateRegion(center: center, span: span)
            if tracking {
                if let lastLocation = self.locations.last {
                    let location = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
                    if !paused {
                        self.distance += $0.distance(from: location) / 1000
                        
                    }
                    
                }
                self.locations.append($0.coordinate)
            }
        }
        speed = manager.location?.speed ?? 0
        
    }

}

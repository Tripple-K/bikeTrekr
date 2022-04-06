
import SwiftUI
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion()
    @Published var speed = CLLocationSpeed()
    @Published var distance: Double
    var speeds = [CLLocationSpeed]()
    var avgSpeed: CLLocationSpeed {
        return speeds.reduce(0,+)/Double(speeds.count)
    }
    private let manager = CLLocationManager()
    var locations2d: [CLLocationCoordinate2D]
    var locations: [CLLocation]
    
    private var cancellables: Set<AnyCancellable> = []
    
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
    
    var canWeStart = false
    
    override init() {
        locations2d = []
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
        
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            canWeStart = false
        case .authorizedAlways, .authorizedWhenInUse:
            canWeStart = true
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        speeds.append(contentsOf: locations.map{$0.speed})
        if let lastLoc = locations.last {
            self.locations.append(lastLoc)
        }
        
        
        locations.last.map {
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            region = MKCoordinateRegion(center: center, span: span)
            if tracking {
                if let lastLocation = self.locations2d.last {
                    let location = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
                    if !paused {
                        self.distance += $0.distance(from: location) / 1000
                    }
                    
                }
                self.locations2d.append($0.coordinate)
            }
        }
        speed = manager.location?.speed ?? 0
        
    }

}

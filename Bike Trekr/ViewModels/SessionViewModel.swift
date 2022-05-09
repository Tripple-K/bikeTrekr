
import CoreLocation
import Combine
import MapKit
import FirebaseAuth
import HealthKit

class SessionViewModel: NSObject, ObservableObject, Identifiable, CLLocationManagerDelegate {
    @Published var session: Session
    @Published var region = MKCoordinateRegion()
    @Published var speed = CLLocationSpeed()
    @Published var status: StatusSession = .stop
    
    
    private var cancellables: Set<AnyCancellable> = []
    private let manager = CLLocationManager()
    let healthAssistant = HealthAssistant()
    var canStart = false
    
    var seconds = 0
    var timer = Timer()
    
    override init () {
        session = Session()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.activityType = .fitness
        manager.distanceFilter = 5
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let last = locations.last {
            if last.horizontalAccuracy <= 100 {
                canStart = true
            }
        }
        
        locations.last.map { cllocation in
            let location = Location(location: cllocation)
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            region = MKCoordinateRegion(center: center, span: span)
            
            if let lastLocation = self.session.locations.last {
                if status == .running {
                    self.session.distance += location.distance(lastLocation) / 1000
                }
                
            }
            self.session.locations.append(location)
            speed = manager.location?.speed ?? 0
        }
        
    }
    
    func pause() {
       
        switch status {
        case .pause:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.seconds += 1
                self.session.duration = "\(String(format: "%02d", self.seconds / 3600)):\(String(format: "%02d", (self.seconds % 3600) / 60)):\(String(format: "%02d", (self.seconds % 3600) % 60))"
            }
            status = .running
        case .stop:
            break
        case .running:
            timer.invalidate()
            status = .pause
        }
    }
    
    func start() {
        let type = session.typeSession
        session = Session()
        session.typeSession = type
        speed = 0
        status = .running
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.seconds += 1
            self.session.duration = "\(String(format: "%02d", self.seconds / 3600)):\(String(format: "%02d", (self.seconds % 3600) / 60)):\(String(format: "%02d", (self.seconds % 3600) % 60))"
        }
    }
    
    func finish() {
        healthAssistant.didAddSession(with: session)
        canStart = false
        speed = 0
        status = .stop
        
        manager.allowsBackgroundLocationUpdates = false
        manager.stopMonitoringSignificantLocationChanges()
        let type = session.typeSession
        session = Session()
        session.typeSession = type
        timer.invalidate()
        seconds = 0
        
    }
}

enum StatusSession {
    case pause, stop, running
}

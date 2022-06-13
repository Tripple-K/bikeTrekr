
import CoreLocation
import Combine
import MapKit
import FirebaseAuth
import HealthKit
import FirebaseFirestore
import SwiftUI

class SessionViewModel: NSObject, ObservableObject, Identifiable, CLLocationManagerDelegate {
    @Published var session: Session
    @Published var region = MKCoordinateRegion()
    @Published var speed = CLLocationSpeed()
    @Published var status: StatusSession = .stop
    @Published var duration = "00:00:00"
    @Published var distance = 0.0
    
    @AppStorage("goal") var goal: GoalType = .none
    
    private let store = Firestore.firestore()
    private let path: String = "sessions"
    private var cancellables: Set<AnyCancellable> = []
    private let manager = CLLocationManager()
    var canStart = false
    
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
        $session
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.duration = "\(String(format: "%02d",  $0.duration / 3600)):\(String(format: "%02d", ($0.duration % 3600) / 60)):\(String(format: "%02d", ($0.duration % 3600) % 60))"
            }
            .store(in: &cancellables)
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
            
            speed = (manager.location?.speed ?? 0) * 3.6
            
            guard status == .running else { return }
            
            if let lastLocation = self.session.intervals.last?.locations.last {
                self.distance += location.distance(lastLocation) / 1000
            }
            
            if self.session.intervals.count < Int(distance + 1) && self.session.goal != .speed {
                let interval = Interval(index: Int(distance + 1))
                self.session.intervals.append(interval)
            }
            
            guard let last = self.session.intervals.last else { return }
            self.session.intervals[last.index - 1].locations.append(location)
            self.session.intervals[last.index - 1].speeds.append((manager.location?.speed ?? 0) * 3.6)
            if self.session.goal != .speed {
                self.session.intervals[last.index - 1].distance = self.distance.truncatingRemainder(dividingBy: 1)
            } else {
                self.session.intervals[last.index - 1].distance = self.distance
            }
            
            saveTemp()
            
        }
        
    }
    
    func addInterval() {
        self.distance = 0
        if let last = self.session.intervals.last {
            let interval = Interval(index: last.index + 1)
            self.session.intervals.append(interval)
        } else {
            let interval = Interval()
            self.session.intervals.append(interval)
        }
    }
    
    func pause() {
        
        switch status {
        case .pause:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                guard let last = self.session.intervals.last else { return }
                self.session.intervals[last.index - 1].duration += 1
                
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
        session.goal = goal
        if session.goal == .speed {
            addInterval()
        }
        session.typeSession = type
        speed = 0
        status = .running
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let last = self.session.intervals.last else { return }
            self.session.intervals[last.index - 1].duration += 1
        }
        getTemp()
    }
    
    func finish() {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        session.userId = userId
        
        if session.distance > 0 {
            save()
        }
        
        removeTemp()
        HealthAssistant.shared.didAddSession(with: session)
        canStart = false
        speed = 0
        distance = 0
        status = .stop
        MapView.view.removeOverlays(MapView.view.overlays)
        manager.allowsBackgroundLocationUpdates = false
        manager.stopMonitoringSignificantLocationChanges()
        let type = session.typeSession
        session = Session()
        session.typeSession = type
        session.goal = goal
        timer.invalidate()
        
    }
    
    func saveTemp() {
        guard status != .stop else { return }
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(SessionDefaults(session)) {
            UserDefaults.standard.set(data, forKey: "session")
        }
    }
    
    func removeTemp() {
        
        UserDefaults.standard.removeObject(forKey: "session")
        
    }
    
    func getTemp() {
        
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.object(forKey: "session") as? Data {
            if let session = try? decoder.decode(SessionDefaults.self, from: data) {
                self.session = Session(session)
                loadPolyline()
            }
        }
    }
    
    func loadPolyline() {
        var locations = [CLLocationCoordinate2D]()
        session.intervals.forEach { interval in
            locations.append(contentsOf: interval.locations.compactMap { location -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            })
        }
        
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        MapView.view.addOverlay(polyline, level: .aboveRoads)
    }
    
    private func save() {
        guard let userId = session.userId else { return }
        do {
            _ = try store.collection(path).addDocument(from: session)
        } catch {
            print("Unable to add session: \(error.localizedDescription).")
        }
    }
    
}

enum StatusSession {
    case pause, stop, running
}

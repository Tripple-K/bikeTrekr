
import CoreLocation
import Combine
import MapKit
import FirebaseAuth
import HealthKit
import FirebaseFirestore
import FirebaseDatabaseSwift

class SessionViewModel: NSObject, ObservableObject, Identifiable, CLLocationManagerDelegate {
    @Published var session: Session
    @Published var region = MKCoordinateRegion()
    @Published var speed = CLLocationSpeed()
    @Published var status: StatusSession = .stop
    @Published var duration = "00:00:00"
    
    private let store = Firestore.firestore()
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
                self.session.duration += 1
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
            self.session.duration += 1
        }
        getTemp()
    }
    
    func finish() {
        removeTemp()
        HealthAssistant.shared.didAddSession(with: session)
        canStart = false
        speed = 0
        status = .stop
        
        manager.allowsBackgroundLocationUpdates = false
        manager.stopMonitoringSignificantLocationChanges()
        let type = session.typeSession
        session = Session()
        session.typeSession = type
        timer.invalidate()
        
    }
    
    func saveTemp() {
        guard status != .stop else { return }
        guard let userId = UserRepository.shared.userInfo?.userId else { return }
        
        
        store.collection("session")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshop, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let document = snapshop?.documents.first else {
                    do {
                        self.session.userId = userId
                        _ = try self.store.collection("session").addDocument(from: self.session)
                    } catch {
                        print("Unable to add session: \(error.localizedDescription).")
                    }
                    return
                }
                
                do {
                    self.session.userId = userId
                    try self.store.collection("session").document(document.documentID).setData(from: self.session)
                } catch {
                    print("Unable to update session: \(error.localizedDescription).")
                }
            }
        
    }
    
    func removeTemp() {
        guard let userId = UserRepository.shared.userInfo?.userId else { return }
        
        store.collection("session")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshop, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let document = snapshop?.documents.first else {
                    return
                }
                
                self.store.collection("session").document(document.documentID).delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        
    }
    
    func getTemp() {
        guard let userId = UserRepository.shared.userInfo?.userId else { return }
        
        store.collection("session")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshop, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let document = snapshop?.documents.first else {
                    return
                }
                if let session = try? document.data(as: Session.self) {
                    self.session = session
                    self.loadPolyline()
                }
            }
    }
    
    func loadPolyline() {
        let coordinates = session.locations.sorted(by: {
            $0.timestamp < $1.timestamp
        }).compactMap { location -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        MapView.mapView.addOverlay(polyline, level: .aboveRoads)
    }
}

enum StatusSession {
    case pause, stop, running
}

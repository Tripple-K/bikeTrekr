

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


class SessionRepository: ObservableObject {
    
    static var shared = SessionRepository()
    
    private let path: String = "sessions"
    private let store = Firestore.firestore()
    
    @Published var isLoading = false
    @Published var sessions: [Session] = []
    
    var userId = ""
    
    private let authenticationService = AuthenticationService()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.get()
            }
            .store(in: &cancellables)
    }
    
    func get() {
        
        isLoading = true
        store.collection(path)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting sessions: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                
                self.sessions = documents.compactMap { document -> Session? in
                    return try? document.data(as: Session.self)
                }
                self.sessions.sort(by: {
                    $0.date > $1.date
                })
                
                self.isLoading = false
                
            }
    }
    
    func getPeriods(_ period: Period) -> [String] {
        guard period != .all else { return [] }
        var set = Set<String>()
        
        sessions.forEach {
            switch period {
            case .week:
                set.insert($0.week)
            case .month:
                set.insert($0.month)
            case .year:
                set.insert($0.year)
            default: break
            }
        }
        return Array(set.reversed())
    }

    
    func add(_ session: Session) {
        do {
            var newSession = session
            newSession.userId = userId
            _ = try store.collection(path).addDocument(from: newSession)
        } catch {
            print("Unable to add session: \(error.localizedDescription).")
        }
    }
    
    func update(_ session: Session) {
        
        guard let sessionId = session.id else { return }
        
        
        do {
            
            try store.collection(path).document(sessionId).setData(from: session)
        } catch {
            print("Unable to update session: \(error.localizedDescription).")
        }
    }
    
    func remove(_ session: Session) {
        
        guard let sessionId = session.id else { return }
        
        store.collection(path).document(sessionId).delete { error in
            if let error = error {
                print("Unable to remove session: \(error.localizedDescription)")
            }
        }
    }
}


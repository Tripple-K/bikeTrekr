

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


class SessionRepository: ObservableObject {
    
    static var shared = SessionRepository()
    
    private let path: String = "sessions"
    private let store = Firestore.firestore()
    
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
               
            }
    }
    
    
    func add(_ session: Session) {
        do {
            var newSession = session
            newSession.userId = userId
            _ = try store.collection(path).addDocument(from: newSession)
        } catch {
            fatalError("Unable to add session: \(error.localizedDescription).")
        }
    }
    
    func update(_ session: Session) {
        
        guard let sessionId = session.id else { return }
        
        
        do {
            
            try store.collection(path).document(sessionId).setData(from: session)
        } catch {
            fatalError("Unable to update card: \(error.localizedDescription).")
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



import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine


class UserRepository: ObservableObject {
    
    static var shared = UserRepository()
    
    private let path: String = "usersInfo"
    private let store = Firestore.firestore()
    
    @Published var userInfo: UserInfo?
    
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
                    print("Error getting cards: \(error.localizedDescription)")
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    return
                }
                self.userInfo = try? document.data(as: UserInfo.self)
            }
    }
    
    func isExist(with email: String, and userId: String, completion: @escaping (Bool) -> Void) {
        store.collection(path)
            .whereField("email", isEqualTo: email)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting cards: \(error.localizedDescription)")
                    completion(false)
                }
                guard let _ = querySnapshot?.documents.first else {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
    
    
    func add(_ user: UserInfo) {
        do {
            var newUser = user
            newUser.id = userId
            _ = try store.collection(path).addDocument(from: newUser)
        } catch {
            print("Unable to add user: \(error.localizedDescription).")
        }
    }
}

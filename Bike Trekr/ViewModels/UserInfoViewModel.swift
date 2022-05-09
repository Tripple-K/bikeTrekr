import Foundation
import Combine
import FirebaseFirestore

class UserInfoViewModel: ObservableObject, Identifiable {
    @Published var userInfo: UserInfo
    private let path: String = "usersInfo"
    private let store = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []
    var id = ""
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
        $userInfo
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func update() {
        guard let userId = userInfo.id else { return }
        do {
            try store.collection(path).document(userId).setData(from: userInfo)
        } catch {
            print("Unable to update user: \(error.localizedDescription).")
        }
    }
    
    func remove() {
        
        guard let userId = userInfo.id else { return }
        
        store.collection(path).document(userId).delete { error in
            if let error = error {
                print("Unable to remove user: \(error.localizedDescription)")
            }
        }
    }
}

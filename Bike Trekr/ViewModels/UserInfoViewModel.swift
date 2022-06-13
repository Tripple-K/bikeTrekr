import Foundation
import Combine
import FirebaseFirestore

class UserInfoViewModel: ObservableObject, Identifiable {
    
    @Published var userInfo: UserInfo
    private let path: String = "usersInfo"
    private let store = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []
    var userId = ""
    
    var isValid: Bool {

        if userInfo.displayName.count > 50 || userInfo.displayName.count < 4 {
            return false
        }
        let age = Calendar.current.dateComponents([.year], from: userInfo.birthday, to: .now)
        if age.year ?? 0 < 16 {
            return false
        }
        if userInfo.height > 300 || userInfo.height < 90 {
            return false
        }
        if userInfo.weight > 300 || userInfo.weight < 25 {
            return false
        }
        return true
    }
    
    init() {
        userInfo = UserInfo()
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

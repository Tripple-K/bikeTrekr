import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase


class AuthenticationService: ObservableObject {
    
    @Published var user: User?
    private var authenticationStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        addListeners()
    }
    
    private func addListeners() {
        if let handle = authenticationStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        authenticationStateHandler = Auth.auth()
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
    
    
    func logOut() {
        try! Auth.auth().signOut()
    }
    
}


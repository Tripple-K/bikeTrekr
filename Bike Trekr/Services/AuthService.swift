import FirebaseAuth


class AuthenticationService: ObservableObject {
    
    @Published var user: User? = Auth.auth().currentUser
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


import Foundation
import FirebaseAuth

struct GitHub {
    
    static var shared = GitHub()
    var provider: OAuthProvider
    
    init () {
        provider = OAuthProvider(providerID: "github.com")
        provider.scopes = ["user:email"]
    }
    
    func processLogin() {
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    guard let credential = authResult?.credential as? OAuthCredential else { return }
                }
            }
        }
    }
}


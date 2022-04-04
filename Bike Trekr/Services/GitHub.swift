import Foundation
import FirebaseAuth

struct GitHub {
    
    static var shared = GitHub()
    var provider: OAuthProvider
    
    init () {
        provider = OAuthProvider(providerID: "github.com")
        provider.scopes = ["user:email"]
    }
    
    func processLogin(completion: @escaping () -> Void) {
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    guard let _ = authResult?.credential as? OAuthCredential else { return }
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = authResult?.user.photoURL
                    changeRequest?.commitChanges { result in
                        if let errorChangeRequest = result {
                            print(errorChangeRequest.localizedDescription)
                        }
                    }
                    completion()
                }
            }
        }
    }
}


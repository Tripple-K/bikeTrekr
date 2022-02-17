
import SwiftUI
import SwiftUIFontIcon
import FirebaseAuth
import CryptoKit
import AuthenticationServices

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userRepo = UserRepository()
    
    @Binding var showLogin: Bool
    @State var currentNonce:String?
    
    var body: some View {
        VStack {
            Spacer()
            Text("Bike Trekr").font(.largeTitle).bold()
            Spacer()
            Spacer()
            Button(action: {
                if Auth.auth().currentUser != nil {
                    showLogin = false
                } else {
                    GitHub.shared.processLogin {
                        showLogin = false
                        guard let user = Auth.auth().currentUser, let _ = user.displayName, let _ = user.email else { return }
                        userRepo.isExist(with: user.uid) { exist in
                            if !exist {
                                userRepo.add(UserInfo(userId: user.uid, displayName: user.displayName!, email: user.email!))
                            }
                        }
                    }
                }
            }) {
                FontIcon.text(.ionicon(code: .logo_github), fontsize: 20)
                    .padding([.top, .leading, .bottom])
                
                Text("Sign up with GitHub")
                    .padding([.top, .bottom, .trailing])
                
            }
            .background(Color.red)
            .cornerRadius(10)
            .foregroundColor(.white)
            .padding(.all)
            
            SignInWithAppleButton(onRequest: {request in
                let nonce = AppleAuth.shared.randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            }, onCompletion: {result in
                switch result {
                case .success(let authResults):
                    switch authResults.credential {
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        
                        guard let nonce = currentNonce else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let appleIDToken = appleIDCredential.identityToken else {
                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                        }
                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                            return
                        }
                        
                        let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                        Auth.auth().signIn(with: credential) { (authResult, error) in
                            if (error != nil) {
                                // Error. If error.code == .MissingOrInvalidNonce, make sure
                                // you're sending the SHA256-hashed nonce as a hex string with
                                // your request to Apple.
                                print(error?.localizedDescription as Any)
                                return
                            }
                            showLogin = false
                            guard let user = Auth.auth().currentUser, let _ = user.displayName, let _ = user.email else { return }
                            userRepo.isExist(with: user.uid) { exist in
                                if !exist {
                                    userRepo.add(UserInfo(userId: user.uid, displayName: user.displayName!, email: user.email!))
                                }
                            }
                        }
                        
                        print("\(String(describing: Auth.auth().currentUser?.uid))")
                    default:
                        break
                        
                    }
                default:
                    break
                }
            }).frame(width: 180, height: 45, alignment: .center)
        }
        
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}


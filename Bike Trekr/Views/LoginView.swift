
import SwiftUI
import SwiftUIFontIcon
import FirebaseAuth
import CryptoKit
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var currentNonce:String?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Text("Bike Trekr").font(.largeTitle).bold()
                Spacer(minLength: geometry.size.height * 0.7)
                VStack (spacing: 0) {
                    Group {
                        Button(action: {
                            GitHub.shared.processLogin {
                                guard let user = Auth.auth().currentUser, let name = user.displayName, let email = user.email else { return }
                                UserRepository.shared.isExist(with: email, and: user.uid) { exist in
                                    if !exist {
                                        UserRepository.shared.add(UserInfo(userId: user.uid, displayName: name, email: email))
                                    }
                                }
                            }
                        }) {
                            FontIcon.text(.ionicon(code: .logo_github), fontsize: 20)
                                .padding([.top, .leading, .bottom])
                            
                            Text("Sign in with GitHub")
                                .font(.system(size: 19))
                                .bold()
                                .padding([.top, .bottom, .trailing])
                            
                        }
                        .frame(maxWidth: geometry.size.width * 0.7, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding()
                        
                        
                        DynamicAppleSignIn(onRequest: { request in
                            let nonce = AppleAuth.shared.randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        }, onCompletion: { result in
                            handleResultAuth(result)
                        })
                            .frame(maxWidth: geometry.size.width * 0.7, alignment: .center)
                            .frame(minHeight: 50)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .frame(maxWidth: geometry.size.width)
                .frame(height: geometry.size.height * 0.1)
                Spacer()
            }
            
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
    
    func handleResultAuth(_ result: Result<ASAuthorization, Error>) {
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
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error?.localizedDescription as Any)
                        return
                    }
                    guard let user = Auth.auth().currentUser else {
                        print("No user")
                        return
                    }
                    UserRepository.shared.isExist(with: user.email!, and: user.uid) { exist in
                        if !exist {
                            UserRepository.shared.add(UserInfo(userId: user.uid, displayName: user.displayName ?? "User", email: user.email!))
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
    }
}


struct DynamicAppleSignIn : View {
    @Environment(\.colorScheme) var colorScheme
    
    var onRequest: (ASAuthorizationAppleIDRequest) -> Void
    var onCompletion: ((Result<ASAuthorization, Error>) -> Void)
    
    var body: some View {
        
        switch colorScheme {
        case .dark:
            SignInWithAppleButton(
                onRequest: onRequest,
                onCompletion: onCompletion
            ).signInWithAppleButtonStyle(.white)
        case .light:
            SignInWithAppleButton(
                onRequest: onRequest,
                onCompletion: onCompletion
            ).signInWithAppleButtonStyle(.black)
        @unknown default:
            fatalError("Not Yet Implemented")
        }
        
    }
}

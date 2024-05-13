import SwiftUI
import MapKit
import LiveViewNative
import GoogleSignInSwift
import GoogleSignIn

@_documentation(visibility: public)
@LiveElement
struct GoogleButton<Root: RootRegistry>: View {
    
    var body: some View {
        GoogleSignInButton(action: handleSignInButton)
    }
    
    func handleSignInButton() {
        var firstKeyWindow: UIWindow? {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.keyWindow
            
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: (firstKeyWindow?.rootViewController)!) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            signInResult.user.refreshTokensIfNeeded { user, error in
                guard error == nil else { return }
                guard let user = user else { return }
                
                let idToken = user.idToken
                print(idToken?.tokenString)
                // Send ID token to backend (example below).
            }
        }
        
    }
}


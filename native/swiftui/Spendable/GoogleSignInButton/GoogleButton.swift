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
            guard let result = signInResult else {
                return
            }
            print(result)
            // If sign in succeeded, display the app's main content View.
        }
        
    }
}


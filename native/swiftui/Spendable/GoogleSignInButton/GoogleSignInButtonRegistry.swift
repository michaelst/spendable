import LiveViewNative
import LiveViewNativeStylesheet
import SwiftUI

/// A registry that includes the ``Map`` element and associated modifiers.
public enum GoogleSignInButtonRegistry<Root: RootRegistry>: CustomRegistry {
    public enum TagName: String {
        case google = "GoogleSignInButton"
    }
    
    public static func lookup(_ name: TagName, element: ElementNode) -> some View {
        switch name {
        case .google:
            GoogleButton<Root>()
        }
    }
}

//
//  ContentView.swift
//  Spendable
//

import SwiftUI
import LiveViewNative
import GoogleSignInSwift
import GoogleSignIn
import LiveViewNativeGoogleSignIn

struct ContentView: View {
    var body: some View {
        #LiveView(
            .automatic(
                development: URL(string: "https://dev.spendable.money")!,
                production: URL(string: "https://spendable.money")!
            ),
            addons: [GoogleSignInRegistry<_>.self]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
    }
}

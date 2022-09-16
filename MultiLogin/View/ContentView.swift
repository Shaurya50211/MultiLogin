//
//  ContentView.swift
//  MultiLogin
//
//  Created by Shaurya Gupta on 2022-09-12.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        if loginModel.logStatus {
            // MARK: HOME VIEW
            DemoHome()
        } else {
            Login()
        }
    }
    
    @ViewBuilder
    func DemoHome()-> some View {
        NavigationStack {
            Text("Logged In")
                .navigationTitle("Multi-Login")
                .toolbar {
                    ToolbarItem {
                        Button("Logout") {
                            try? Auth.auth().signOut()
                            GIDSignIn.sharedInstance.signOut()
                            withAnimation(.easeInOut) {
                                loginModel.logStatus = false
                            }
                        }
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

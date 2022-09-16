//
//  LoginViewModel.swift
//  MultiLogin
//
//  Created by Shaurya Gupta on 2022-09-13.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

class LoginViewModel: ObservableObject {
    // MARK: View Properties
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    // MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    // MARK: Firebase API's
    func getOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                // MARK: Disable this when testing on real device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    
                    // MARK: Enabling OTP Field When its success
                    withAnimation(.easeInOut) {
                        showOTPField = true
                    }
                })
                
            } catch {
                await handleError(error)
            }
        }
    }
    
    func verifyOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                try await Auth.auth().signIn(with: credential)
                
                // MARK: User logged in successfully
                print("Success!")
                await MainActor.run {
                    withAnimation {
                        logStatus = true
                    }
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    // MARK: Handling Error
    func handleError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    // MARK: Logging Google User into Firebase
    func logGoogle(user: GIDGoogleUser) {
        Task {
            do {
                guard let idToken = user.authentication.idToken else {return}
                let accessToken = user.authentication.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken   )
                
                try await Auth.auth().signIn(with: credential)
                
                print("Success Google Sign In!")
                
                await MainActor.run(body: {
                    withAnimation(.easeInOut) {
                        logStatus = true
                    }
                })
            } catch {
                await handleError(error)
            }
        }
    }
}

// MARK: Extensions

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Root Controller
    func rootController()->UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else { return .init() }
        guard let viewController = window.windows.last?.rootViewController else {return .init()}
        
        return viewController
    }
}

//
//  Login.swift
//  MultiLogin
//
//  Created by Shaurya Gupta on 2022-09-13.
//

import SwiftUI
import RiveRuntime
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct Login: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        ZStack {
            // rgb(254, 251, 230)
            Color(UIColor(red: 1.00, green: 0.98, blue: 0.90, alpha: 1.00))
            
                .ignoresSafeArea()
            RiveViewModel(fileName: "shapes").view()
                .ignoresSafeArea(.all)
                .blur(radius: 30)
            ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15) {
                    Image(systemName: "triangle")
                        .font(.system(size: 30))
                        .foregroundColor(Color(.systemIndigo))
                    
                    (Text("Welcome,")
                        .foregroundColor(.black) +
                     Text("\nLogin to continue")
                        .foregroundColor(.black.opacity(0.6))
                    )
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineSpacing(10)
                    .padding(.top, 20)
                    .padding(.trailing, 15)
                    
                    // MARK: Custom TextField
                    CustomTextField(hint: "16505551234", text: $loginModel.mobileNo)
                        .disabled(loginModel.showOTPField)
                        .opacity(loginModel.showOTPField ? 0.4 : 1)
                        .overlay(alignment: .trailing, content: {
                            Button("Change") {
                                withAnimation(.easeInOut) {
                                    loginModel.showOTPField = false
                                    loginModel.otpCode = ""
                                    loginModel.CLIENT_CODE = ""
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.indigo)
                            .opacity(loginModel.showOTPField ? 1 : 0)
                            .padding(.trailing, 15)
                        })
                        .padding(.top, 50)
                        .padding(.trailing, 15)
                        .foregroundColor(.black)
                    
                    CustomTextField(hint: "123456", text: $loginModel.otpCode)
                        .disabled(!loginModel.showOTPField)
                        .opacity(!loginModel.showOTPField ? 0.4 : 1)
                        .padding(.top, 20)
                        .padding(.trailing, 15)
                    
                    Button(action: loginModel.showOTPField ? loginModel.verifyOTPCode : loginModel.getOTPCode) {
                        HStack(spacing: 15) {
                            Text(loginModel.showOTPField ? "Verify OTP" :  "Get Code")
                                .fontWeight(.semibold)
                                .contentTransition(.identity)
                                .foregroundColor(Color(.black))
                            
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .padding(.leading, -5)
                                .foregroundColor(Color(.black))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.black).opacity(0.08))
                        }
                    }
                    .padding(.top, 30)
                    Text("(OR)")
                        .foregroundColor(Color(.black).opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        .padding(.leading, -60)
                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        // MARK: Custom Sign in with Google
                        HStack {
                            Image("Google-Dark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .frame(height: 45)
                            
                            Text("Sign in with Google")
                                .font(.callout)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 15)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.black)
                        }
                    }
                    .padding(.leading, 25)
                    .overlay {
                        if let clientID = FirebaseApp.app()?.options.clientID {
                            GoogleSignInButton {
                                GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()) { user, error in
                                    
                                    if let error = error {
                                        print(error.localizedDescription)
                                        return
                                    }
                                    
                                    // MARK: Logging Google User into Firebase
                                    if let user {
                                        loginModel.logGoogle(user: user)
                                    }
                                    
                                }
                            }
                            .blendMode(.overlay)
                            .padding(.leading, 27)
                        }
                    }
                }
                .padding(.leading, 60)
                .padding(.vertical, 15)
            }
            .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {}
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}

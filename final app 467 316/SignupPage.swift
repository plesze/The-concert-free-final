//
//  SignupPage.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct SignupPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomLeading))
                .frame(maxWidth: 300, maxHeight: 460)

            VStack(spacing: 12) {
                Text("Create account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .frame(width: 250)

                SecureField("password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .frame(width: 250)

                SecureField("confirm password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .frame(width: 250)

                Button("Sign up") {
                    signUp()
                }
                .buttonStyle(.borderedProminent)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(width: 260)
                }

                Button("Already have an account? Log in") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields."
  
            return
        }
        guard password == confirmPassword else {
            
            errorMessage = "Passwords do not match."
            
            return
            
        }
        
        guard password.count >= 6 else {
            
            errorMessage = "Password should be at least 6 characters."
            
            return
            
        }

        
        Auth.auth().createUser(withEmail: email, password: password) {_, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            // สมัครเสร็จ ปิดหน้าและกลับไปหน้า Login
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SignupPage()
    }
}

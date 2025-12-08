//
//  SignupPage.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupPage: View {
    // User input states
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var phoneNumber = ""
    
    // Error message for validation/auth failures
    @State private var errorMessage: String?
    
    // Used to dismiss this view (go back)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .frame(maxWidth: 350, maxHeight: 510)

            VStack(spacing: 30) {
                Text("Create account")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 0) {
                    // Username
                    TextField("username", text: $username)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 300, height: 1)
                    
                    // Email
                    TextField("email", text: $email)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 300, height: 1)
                    
                    // Password
                    SecureField("password", text: $password)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 300, height: 1)
                    
                    // Confirm password
                    SecureField("confirm password", text: $confirmPassword)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 300, height: 1)
                    
                    TextField("phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .modifier(PhoneDigitsFilter(phoneNumber: $phoneNumber))
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                )
                
                VStack(spacing: 15) {
                    Button(action: {
                            signUp()
                        }) {
                            Text("Sign up")
                                .foregroundColor(.white)
                                .frame(width: 300, height: 45)
                                .background(Color.red)
                                .cornerRadius(15)
                        }
                    
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
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // Handles local validation, Firebase Auth account creation, and Firestore profile save.
    private func signUp() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !username.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        // Confirm password matches
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        // Minimum password length
        guard password.count >= 6 else {
            errorMessage = "Password should be at least 6 characters."
            return
        }
        // Simple phone validation (allow 9-15 digits)
        let digits = phoneNumber.filter { $0.isNumber }
        guard digits.count >= 9 && digits.count <= 15 else {
            errorMessage = "Please enter a valid phone number."
            return
        }

        // Create user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let uid = result?.user.uid else {
                errorMessage = "Cannot get user id."
                return
            }

            let db = Firestore.firestore()
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "username": username,
                "phone": phoneNumber,
                "createdAt": Timestamp(date: Date())
            ]

            db.collection("users").document(uid).setData(data) { err in
                if let err = err {
                    errorMessage = "Failed to save profile: \(err.localizedDescription)"
                    return
                }
                dismiss()
            }
        }
    }
}

// ViewModifier that filters non-digit characters from phoneNumber as the user types.
private struct PhoneDigitsFilter: ViewModifier {
    @Binding var phoneNumber: String

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: phoneNumber) { oldValue, newValue in
                    phoneNumber = newValue.filter { $0.isNumber }
                }
        } else {
            content
                .onChange(of: phoneNumber) { newValue in
                    phoneNumber = newValue.filter { $0.isNumber }
                }
        }
    }
}

#Preview {
    NavigationStack {
        SignupPage()
    }
}

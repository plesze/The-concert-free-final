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
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomLeading))
                .frame(maxWidth: 300, maxHeight: 540)

            VStack(spacing: 12) {
                Text("Create account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // ย้าย username มาไว้บนสุด
                TextField("username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .frame(width: 250)

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

                TextField("phone number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
            .padding(.horizontal, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signUp() {
        // Basic validations
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !username.isEmpty, !phoneNumber.isEmpty else {
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
        // Simple phone validation (digits 9-15)
        let digits = phoneNumber.filter { $0.isNumber }
        guard digits.count >= 9 && digits.count <= 15 else {
            errorMessage = "Please enter a valid phone number."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let uid = result?.user.uid else {
                errorMessage = "Cannot get user id."
                return
            }

            // Save profile to Firestore
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
                // Success: dismiss back to Login
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignupPage()
    }
}

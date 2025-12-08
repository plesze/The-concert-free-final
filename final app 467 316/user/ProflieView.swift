//
//  ProflieView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ThemeColor<Content: View>: View {
    @ViewBuilder var content: Content
    @AppStorage("AppthemeColor") private var selectedTheme: AppthemeColor = .systeamdefault
    var body: some View{
        content
            .preferredColorScheme(selectedTheme.colorScheme)
    }
}

enum AppthemeColor: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case systeamdefault = "default"
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .systeamdefault:
            return nil
        }
    }
    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .systeamdefault: return "System"
        }
    }
}

struct ProflieView: View {
    @AppStorage("AppthemeColor") private var selectedTheme: AppthemeColor = .systeamdefault
    @Binding var selectedTab: Int
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    @State private var username: String = ""
    @State private var phone: String = ""
    @State private var isLoadingProfile: Bool = false
    @State private var profileError: String?
    
    @State private var showEditUsername = false
    @State private var showChangePassword = false

    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var passwordErrorMessage: String?

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if isLoggedIn {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PROFILE")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let email = Auth.auth().currentUser?.email {
                                Text(email)
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Section("Information") {
                        if isLoadingProfile {
                            HStack(spacing: 10) {
                                ProgressView().tint(.primary)
                                Text("กำลังโหลดข้อมูลโปรไฟล์...")
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            if !username.isEmpty {
                                HStack {
                                    Text("Username")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(username)
                                        .foregroundColor(.primary)
                                }
                            }
                            if !phone.isEmpty {
                                HStack {
                                    Text("Phone")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(phone)
                                        .foregroundColor(.primary)
                                }
                            }
                            if username.isEmpty && phone.isEmpty && profileError == nil {
                                Text("ยังไม่มีข้อมูลโปรไฟล์")
                                    .foregroundColor(.secondary)
                            }
                            if let profileError = profileError {
                                Text(profileError)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Section("Appearance") {
                        Picker("Theme", selection: $selectedTheme) {
                            ForEach(AppthemeColor.allCases, id: \.rawValue) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Account") {
                        Button("Edit Username") {
                            newUsername = username
                            showEditUsername = true
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.visible)

                        Button("Change Password") {
                            // reset fields each time opening
                            newPassword = ""
                            confirmNewPassword = ""
                            passwordErrorMessage = nil
                            showChangePassword = true
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.visible)

                        Button(role: .destructive) {
                            signOut()
                        } label: {
                            Text("Log out")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowSeparator(.visible)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .onAppear {
                    isLoggedIn = Auth.auth().currentUser != nil
                    fetchProfile()
                }

            } else {
                VStack(spacing: 16) {
                    Text("PLEASE LOGIN OR REGISTER")
                        .foregroundColor(.primary)
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    NavigationLink {
                        Loginpage(selectedTab: $selectedTab)
                    } label: {
                        Text("Log in")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 160)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(Color.red)
                            )
                    }
                    .shadow(color: Color.red.opacity(0.25), radius: 6, x: 0, y: 4)

                }
                .onAppear {
                    isLoggedIn = Auth.auth().currentUser != nil
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        .alert("Edit Username", isPresented: $showEditUsername) {
            TextField("New Username", text: $newUsername)
                .autocorrectionDisabled()
            Button("Save") { updateUsername() }
            Button("Cancel", role: .cancel) {}
        }
        
        .alert("Change Password", isPresented: $showChangePassword) {
            SecureField("New Password", text: $newPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Confirm New Password", text: $confirmNewPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if let msg = passwordErrorMessage, !msg.isEmpty {
                Text(msg).foregroundColor(.red)
            }
            Button("Save") { changePassword() }
                .disabled(!canSaveNewPassword)
            Button("Cancel", role: .cancel) {
                // clear on cancel
                newPassword = ""
                confirmNewPassword = ""
                passwordErrorMessage = nil
            }
        }
    }
    
    private var canSaveNewPassword: Bool {
        !newPassword.isEmpty &&
        !confirmNewPassword.isEmpty &&
        newPassword == confirmNewPassword &&
        newPassword.count >= 6
    }
    
    private func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoadingProfile = true
        profileError = nil

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            isLoadingProfile = false
            if let error = error {
                profileError = "Failed to load profile: \(error.localizedDescription)"
                return
            }
            guard let data = snapshot?.data() else {
                profileError = "Profile not found."
                return
            }
            self.username = data["username"] as? String ?? ""
            self.phone = data["phone"] as? String ?? ""
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            selectedTab = 2
            username = ""
            phone = ""
        } catch {
            // handle error if needed
        }
    }
    
    private func updateUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).updateData([
            "username": newUsername
        ]) { error in
            if let error = error {
                print("Error updating username: \(error.localizedDescription)")
                return
            }
            self.username = newUsername
            showEditUsername = false
        }
    }

    private func changePassword() {
        // local validation
        guard !newPassword.isEmpty, !confirmNewPassword.isEmpty else {
            passwordErrorMessage = "Please fill in both fields."
            return
        }
        guard newPassword.count >= 6 else {
            passwordErrorMessage = "Password should be at least 6 characters."
            return
        }
        guard newPassword == confirmNewPassword else {
            passwordErrorMessage = "Passwords do not match."
            return
        }

        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Password update error: \(error.localizedDescription)")
                passwordErrorMessage = error.localizedDescription
                return
            }
            // success: clear and close
            showChangePassword = false
            passwordErrorMessage = nil
            newPassword = ""
            confirmNewPassword = ""
        }
    }
}

#Preview {
    NavigationStack {
        ProflieView(selectedTab: .constant(2))
    }
}

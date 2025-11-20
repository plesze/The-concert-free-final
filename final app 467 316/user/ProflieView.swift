//
//  ProflieView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProflieView: View {
    @Binding var selectedTab: Int
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    @State private var username: String = ""
    @State private var phone: String = ""
    @State private var isLoadingProfile: Bool = false
    @State private var profileError: String?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if isLoggedIn {
                VStack(spacing: 16) {
                    Text("PROFILE")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.top, 20)

                    if let email = Auth.auth().currentUser?.email {
                        Text(email)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    if isLoadingProfile {
                        ProgressView()
                            .tint(.white)
                    } else {
                        // Show username and phone loaded from Firestore
                        if !username.isEmpty {
                            Text("Username: \(username)")
                                .foregroundColor(.white)
                        }
                        if !phone.isEmpty {
                            Text("Phone: \(phone)")
                                .foregroundColor(.white)
                        }
                        if let profileError = profileError {
                            Text(profileError)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }

                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        Text("Log out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 160)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(Color.red)
                            )
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .onAppear {
                    isLoggedIn = Auth.auth().currentUser != nil
                    fetchProfile()
                }
            } else {
                VStack(spacing: 16) {
                    Text("PLEASE LOGIN OR REGISTER ")
                        .foregroundColor(.white)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    NavigationLink {
                        Loginpage(selectedTab: $selectedTab)
                            .onReceive(NotificationCenter.default.publisher(for: .AuthStateDidChange)) { _ in
                                isLoggedIn = Auth.auth().currentUser != nil
                                if isLoggedIn {
                                    fetchProfile()
                                }
                            }
                    } label: {
                        Text("Log in")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 120)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                    .padding(.horizontal, 32)
                    .shadow(color: .red.opacity(0.35), radius: 5, x: 0, y: 6)
                    .accessibilityLabel("Log in")

                    Spacer()
                }
                .padding(.top, 50)
                .onAppear {
                    isLoggedIn = Auth.auth().currentUser != nil
                }
            }
        }
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
            selectedTab = 2 // อยู่แท็บโปรไฟล์เดิม
            username = ""
            phone = ""
        } catch {
            // จัดการ error ถ้าต้องการ
        }
    }
}

#Preview {
    NavigationStack {
        ProflieView(selectedTab: .constant(2))
    }
}

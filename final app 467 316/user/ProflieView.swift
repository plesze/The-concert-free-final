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

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if isLoggedIn {
                VStack(spacing: 16) {
                    Text("PROFILE")
                        .foregroundColor(.primary)
                        .font(.title2)
                        .padding(.top, 20)
                    
                    if let email = Auth.auth().currentUser?.email {
                        Text(email)
                            .foregroundColor(.secondary)
                    }
                    
                    if isLoadingProfile {
                        ProgressView()
                            .tint(.primary)
                    } else {
                        // Show username and phone loaded from Firestore
                        if !username.isEmpty {
                            Text("Username: \(username)")
                                .foregroundColor(.primary)
                        }
                        if !phone.isEmpty {
                            Text("Phone: \(phone)")
                                .foregroundColor(.primary)
                        }
                        if let profileError = profileError {
                            Text(profileError)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                    NavigationStack{
                        List {
                            Section {
                                Picker("", selection: $selectedTheme) {
                                    ForEach(AppthemeColor.allCases, id: \.rawValue) { theme in
                                        Text(theme.title)
                                            .tag(theme)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                

                    Button(role: .destructive) {
                        signOut()
                    } label: {
                        Text("Log out")
                            .font(.headline)
                            .foregroundColor(.white) // ปุ่มแดงยังคงอ่านง่ายบนทั้งสองธีม
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
                        .foregroundColor(.primary)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    NavigationLink {
                        Loginpage(selectedTab: $selectedTab)
                    } label: {
                        Text("Log in")
                            .font(.headline)
                            .foregroundColor(.white) // ปุ่มแดงยังคงอ่านง่ายบนทั้งสองธีม
                            .frame(maxWidth: 120)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                    .padding(.horizontal, 32)
                    .shadow(color: Color.red.opacity(0.35), radius: 5, x: 0, y: 6)
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

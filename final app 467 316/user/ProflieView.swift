//
//  ProflieView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct ProflieView: View {
    @Binding var selectedTab: Int
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if isLoggedIn {
                // ผู้ใช้ล็อกอินแล้ว: แสดงหน้าโปรไฟล์จริงแทน (ตัวอย่าง)
                VStack(spacing: 16) {
                    Text("PROFILE")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.top, 20)

                    if let email = Auth.auth().currentUser?.email {
                        Text(email)
                            .foregroundColor(.white.opacity(0.9))
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
                    // อัปเดตสถานะทุกครั้งที่เข้าหน้านี้
                    isLoggedIn = Auth.auth().currentUser != nil
                }
            } else {
                // ผู้ใช้ยังไม่ล็อกอิน: แสดงปุ่มไปหน้า Login
                VStack(spacing: 16) {
                    Text("PLEASE LOGIN OR REGISTER ")
                        .foregroundColor(.white)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    NavigationLink {
                        Loginpage(selectedTab: $selectedTab)
                            .onReceive(NotificationCenter.default.publisher(for: .AuthStateDidChange)) { _ in
                                // เผื่อมีการส่ง Notification หลัง login สำเร็จ
                                isLoggedIn = Auth.auth().currentUser != nil
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

    private func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            selectedTab = 2 // อยู่แท็บโปรไฟล์เดิม
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

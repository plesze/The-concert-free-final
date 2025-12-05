//
//  Loginpage.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class SignInViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var errorMessage: String?

    func signIn(identifier: String, password: String) {
        // ถ้าเป็น email, sign in ได้เลย
        if identifier.contains("@") {
            Auth.auth().signIn(withEmail: identifier, password: password) { [weak self] result, error in
                if let _ = error {
                    self?.errorMessage = "Email or password is incorrect"
                    return
                }
                self?.user = result?.user
            }
        } else {
            // identifier เป็น username -> หา email ก่อน
            let db = Firestore.firestore()
            db.collection("users")
                .whereField("username", isEqualTo: identifier)
                .getDocuments { [weak self] snapshot, error in
                    if let _ = error {
                        self?.errorMessage = "Username not found"
                        return
                    }
                    
                    guard let email = snapshot?.documents.first?.data()["email"] as? String else {
                        self?.errorMessage = "Username not found"
                        return
                    }
                    
                    // ใช้ email sign in
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let _ = error {
                            self?.errorMessage = "Password is incorrect"
                            return
                        }
                        self?.user = result?.user
                    }
                }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.errorMessage =
                "email or password is incorrect"
                return
            }
            self?.user = result?.user
        }
    }
}

struct Loginpage: View {
    @Binding var selectedTab: Int
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // ใช้สีระบบเพื่อรองรับ Light/Dark อัตโนมัติ
            Color(.systemBackground).ignoresSafeArea()
            
            // การ์ดใช้พื้นหลังระบบรอง เพื่อคอนทราสต์พอดีทั้งสองโหมด
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .frame(maxWidth: 350, maxHeight: 400)
            
            VStack(spacing: 35) {
                Text("Login to join us")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // กล่องชื่อและรหัส "ติดกัน" โดยแยกเป็น VStack ย่อย spacing: 0
                VStack(spacing: 0) {
                    TextField("email / username", text: $email)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    // เส้นแบ่งบางๆ เพื่อให้ดูติดกันแต่ยังแยกชั้น
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 300, height: 2)
                    
                    SecureField("password", text: $password)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 300, height: 45)
                        .background(Color(.systemBackground))
                        .cornerRadius(15, antialiased: true)
                        .tint(.red)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                // หากอยากให้เป็นการ์ดเดียวกันจริงๆ ลองใช้คลิปและสไตล์มุมด้านบน/ล่างต่างกัน:
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                )
                
                VStack(spacing: 5) {
                    Button(action: {
                        viewModel.signIn(identifier: email, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 45)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .contentShape(Rectangle()) // ทำให้พื้นที่เต็ม frame กดได้
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    NavigationLink(destination: SignupPage()) {
                        Text("Don't have an account yet? Sign up")
                            .foregroundColor(.blue)
                            .padding(.vertical, 5)  // เพิ่มพื้นที่กดรอบข้อความ
                            .padding(.horizontal, 5)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle()) // ทำให้ทั้งพื้นที่เป็นโซนกด
                }
            }
            // ไม่ต้อง ignoresSafeArea แบบทับสีดำทั้งจอแล้ว
            .onReceive(viewModel.$user.compactMap { $0 }) { _ in
                // เมื่อ login สำเร็จ
                selectedTab = 0   // เปลี่ยนไปแท็บ Home
                dismiss()         // ปิดหน้า Login
            }
        }
    }
}
    
    #Preview {
        // ถ้า Preview ไม่ได้อยู่ใน NavigationStack ให้ห่อเพื่อทดสอบ Navigation
        NavigationStack {
            // Provide a constant binding for preview
            Loginpage(selectedTab: .constant(2))
        }
    }


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
        ZStack{
            Color.black
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomLeading))
                .frame(maxWidth: 350, maxHeight: 420)
            VStack{
                Text ("Login to join us")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("email / username", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .frame(width: 250)
                SecureField("password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .frame(width: 250)

                Button("Login"){
                    viewModel.signIn(identifier: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                // นำทางไปหน้า Sign up แยกต่างหาก
                NavigationLink("Sign up") {
                    SignupPage() // หน้าที่จะสมัครสมาชิกจริง
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .ignoresSafeArea(edges: .all)
        .onReceive(viewModel.$user.compactMap { $0 }) { _ in
            // เมื่อ login สำเร็จ
            selectedTab = 0   // เปลี่ยนไปแท็บ Home
            dismiss()         // ปิดหน้า Login
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

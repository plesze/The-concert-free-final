//
//  Loginpage.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseAuth
import Combine

class SignInViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if error != nil {
                self?.errorMessage =
                     "email or password is incorrect"
                return
            }
            self?.user = result?.user
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
    var body: some View {
        ZStack{
            Color.black
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.white, .white], startPoint: .topLeading, endPoint: .bottomLeading))
                .frame(maxWidth: 300, maxHeight: 400)
            VStack{
                Text ("login with email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("email",text:$email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .frame(width: 250)
                SecureField("password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .frame(width: 250)

                Button("Login"){
                    viewModel.signIn(email: email, password: password)
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
        Loginpage(selectedTab: .constant(2))
    }
}

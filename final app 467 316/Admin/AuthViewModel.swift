import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var role: String? = nil        
    @Published var isLoading: Bool = false
    
    private var authListener: AuthStateDidChangeListenerHandle? = nil
    private let db = Firestore.firestore()
    
    init() {
        // ฟังทุกครั้งที่สถานะผู้ใช้เปลี่ยน (ล็อกอิน/ล็อกเอาต์)
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.isAuthenticated = true
                self.fetchRole(for: user.uid)
            } else {
                self.isAuthenticated = false
                self.role = nil
            }
        }
    }
    
    deinit {
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // โหลดว่าเป็น admin หรือ user จากFirestore
    func fetchRole(for uid: String) {
        isLoading = true
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            if let data = snapshot?.data(), error == nil {
                self.role = data["role"] as? String
            } else {
                self.role = nil
            }
        }
    }
    
    
    
}

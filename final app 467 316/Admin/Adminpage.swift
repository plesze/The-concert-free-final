//
//  Adminpage.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Adminpage: View {
    @Environment(\.dismiss) private var dismiss
    // ช่องกรอกข้อมูลแบบง่ายๆ
    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var date: String = ""
    @State private var time: String = ""
    @State private var location: String = ""
    @State private var imageURL: String = ""    // ใส่ลิงก์รูป
    @State private var detail: String = ""
    @State private var mapURL: String = ""      // ลิงก์แผนที่
    
    // สถานะง่ายๆ
    @State private var heading: String = ""
    @State private var isSaving = false
    @State private var saveMessage: String?
    var onSaved: (() -> Void)? = nil

    // การตรวจสิทธิ์แอดมิน
    @State private var isCheckingAdmin = true
    @State private var isAdmin = false
    @State private var authError: String?

    var body: some View {
        NavigationStack {
            Group {
                if isCheckingAdmin {
                    VStack(spacing: 12) {
                        ProgressView().tint(.primary)
                        Text("กำลังตรวจสอบสิทธิ์...")
                            .foregroundColor(.secondary)
                    }
                } else if !isAdmin {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.slash")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("คุณไม่มีสิทธิ์เข้าถึงหน้านี้")
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let authError {
                            Text(authError)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Button("ปิด") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                    .padding()
                } else {
                    Form {
                        Section("ชื่อคอนเสิร์ต") {
                            TextField("Title", text: $title)
                            TextField("Subtitle", text: $subtitle)
                        }
                        
                        Section("วันเวลาและสถานที่") {
                            TextField("Date (เช่น 2025-12-31)", text: $date)
                            TextField("Time (เช่น 20:00)", text: $time)
                            TextField("Location", text: $location)
                        }
                        
                        Section("รูปภาพและแผนที่") {
                            TextField("Image URL", text: $imageURL)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                            TextField("Map URL (เช่น Apple Maps/Google Maps)", text: $mapURL)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                        }
                        
                        Section("รายละเอียด") {
                            TextEditor(text: $detail)
                                .frame(minHeight: 120)
                        }
                        
                        Section {
                            Button {
                                saveConcert()
                            } label: {
                                if isSaving {
                                    ProgressView()
                                } else {
                                    Text("บันทึกคอนเสิร์ต")
                                        .font(.headline)
                                }
                            }
                            .disabled(isSaving || title.isEmpty || imageURL.isEmpty)
                        }
                        
                        if let msg = saveMessage {
                            Section {
                                Text(msg)
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Admin: เพิ่มคอนเสิร์ต")
            .toolbar {
                if isAdmin {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            saveConcert()
                        } label: {
                            if isSaving {
                                ProgressView()
                            } else {
                                Image(systemName: "plus")
                            }
                        }
                        .disabled(isSaving || title.isEmpty || imageURL.isEmpty)
                        .accessibilityLabel("บันทึกคอนเสิร์ต")
                    }
                }
            }
        }
        .task {
            await checkAdminRole()
        }
    }
    
    // ตรวจสอบสิทธิ์แอดมินจาก Firestore
    @MainActor
    private func checkAdminRole() async {
        isCheckingAdmin = true
        authError = nil
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                isAdmin = false
                authError = "กรุณาเข้าสู่ระบบก่อน"
                isCheckingAdmin = false
                return
            }
            let snap = try await Firestore.firestore()
                .collection("users").document(uid).getDocument()
            let role = (snap.data()?["role"] as? String) ?? ""
            isAdmin = (role == "admin")
        } catch {
            isAdmin = false
            authError = error.localizedDescription
        }
        isCheckingAdmin = false
        if !isAdmin {
            // ปิดหน้าอัตโนมัติหลังแจ้งเตือนสั้นๆ (ถ้าอยากให้ปิดเอง ให้ลบส่วนนี้)
            // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
        }
    }

    // บันทึกลง Firestore แบบง่ายๆ
    private func saveConcert() {
        guard isAdmin else { return } // กันกรณีเรียกโดยไม่ใช่แอดมิน
        isSaving = true
        saveMessage = nil
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "title": title,
            "subtitle": subtitle,
            "date": date,
            "time": time,
            "location": location,
            "imageURL": imageURL,
            "detail": detail,
            "mapURL": mapURL.isEmpty ? "http://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : mapURL
        ]
        
        db.collection("concerts").addDocument(data: data) { error in
            isSaving = false
            if let error = error {
                saveMessage = "บันทึกไม่สำเร็จ: \(error.localizedDescription)"
            } else {
                saveMessage = "บันทึกสำเร็จ! กลับไปหน้า Home จะเห็นรายการใหม่"
                
                // ล้างฟอร์มแบบง่ายๆ
                title = ""; subtitle = ""; date = ""; time = ""; location = ""
                imageURL = ""; detail = ""; mapURL = ""
                
                // แจ้ง Home ให้รีโหลด
                onSaved?()
                dismiss()
            }
        }
    }
}

#Preview {
    Adminpage()
}

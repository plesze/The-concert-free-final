import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct ConcertDetailView: View {
    let concert: Homeview.Concert
    @State private var showSuccessAlert = false
    @State private var navigateToLogin = false
    @State private var showLoginAlert = false
    @State private var navigateToTicket = false
    @Environment(\.openURL) private var openURL

    // ข้อมูล ticket ที่สร้าง
    @State private var ticketQR: String = ""
    @State private var ticketDate: Date = Date()

    // แจ้งเตือน “ลงทะเบียนซ้ำ”
    @State private var showAlreadyRegisteredAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        AsyncImage(url: URL(string: concert.imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    ProgressView().tint(.primary)
                                }
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    Image(systemName: "photo").foregroundColor(.secondary)
                                }
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(concert.title)
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(.primary)

                        Text(concert.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            Image(systemName: "calendar").foregroundColor(.green)
                            Text(concert.date).foregroundColor(.green).font(.subheadline)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "clock").foregroundColor(.green)
                            Text(concert.time).foregroundColor(.primary).font(.subheadline)
                        }

                        HStack(alignment: .center, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse").foregroundColor(.blue)
                                Text(concert.location).foregroundColor(.blue).font(.subheadline)
                            }
                            Spacer(minLength: 8)
                            Button {
                                if let url = URL(string: concert.mapURL) {
                                    openURL(url)
                                } else if let url = mapsURL(for: concert.location) {
                                    openURL(url)
                                }
                            } label: {
                                Label("เปิดแผนที่", systemImage: "arrow.turn.up.right")
                                    .font(.callout.weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Capsule().fill(Color.blue.opacity(0.8)))
                            }
                            .buttonStyle(.plain)
                        }

                        Text(concert.detail).foregroundColor(.primary)

                        Button {
                            if Auth.auth().currentUser == nil {
                                showLoginAlert = true
                            } else {
                                registerTicket()
                            }
                        } label: {
                            Text("ลงทะเบียน")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(Color.red))
                        }
                        .padding(.top, 8)
                        .shadow(color: .red.opacity(0.35), radius: 5, x: 0, y: 6)
                    }
                    .padding()
                }
            }
            .navigationTitle("รายละเอียดคอนเสิร์ต")
            .navigationBarTitleDisplayMode(.inline)

            .alert("ลงทะเบียนเข้าร่วมสำเร็จ", isPresented: $showSuccessAlert) {
                Button("เข้าใจแล้ว", role: .cancel) { navigateToTicket = true }
            } message: {
                Text("แล้วเจอกันในงาน \(concert.title) !")
            }

            .alert("กรุณาเข้าสู่ระบบก่อนลงทะเบียน", isPresented: $showLoginAlert) {
                Button("เข้าสู่ระบบ") { navigateToLogin = true }
            }

            .alert("คุณลงทะเบียนคอนเสิร์ตนี้ไปแล้ว", isPresented: $showAlreadyRegisteredAlert) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text("ไม่สามารถลงทะเบียนซ้ำได้")
            }

            .navigationDestination(isPresented: $navigateToLogin) {
                Loginpage(selectedTab: .constant(2))
            }

            .navigationDestination(isPresented: $navigateToTicket) {
                TicketDetailView(concert: concert, qrString: ticketQR, registerDate: ticketDate)
            }
        }
    }

    // ขั้นตอนแรก: เช็กก่อนว่าลงทะเบียนคอนเสิร์ตนี้ไปแล้วหรือยัง
    private func registerTicket() {
        guard let user = Auth.auth().currentUser else { return }
        let email = user.email ?? user.uid
        let uid = user.uid
        let db = Firestore.firestore()

        // 1) เช็กซ้ำ: มี ticket ของ user นี้กับ concert นี้อยู่แล้วหรือยัง
        db.collection("tickets")
            .whereField("userEmail", isEqualTo: email)
            .whereField("concertId", isEqualTo: concert.id)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let _ = error {
                    self.showAlreadyRegisteredAlert = true
                    return
                }

                if let snap = snapshot, snap.documents.first != nil {
                    self.showAlreadyRegisteredAlert = true
                    return
                }

                // 2) ยังไม่เคยลง → เดินหน้าสร้างตั๋วใหม่ (แบบ doc id คงที่ ป้องกันซ้ำระดับฐานข้อมูล)
                createTicket(for: email, uid: uid, db: db)
            }
    }

    // สร้างตั๋วด้วย document id คงที่ = "{uid}_{concertId}"
    private func createTicket(for email: String, uid: String, db: Firestore) {
        let fixedDocId = "\(uid)_\(concert.id)"
        let docRef = db.collection("tickets").document(fixedDocId)

        // ถ้าเอกสารมีอยู่แล้ว ไม่ต้องสร้างซ้ำ (กันกรณี race condition)
        docRef.getDocument { snapshot, error in
            if let snapshot, snapshot.exists {
                self.showAlreadyRegisteredAlert = true
                return
            }

            // ค่อยสร้างใหม่
            self.ticketDate = Date()
            self.ticketQR = "ticket:\(fixedDocId)|user:\(email)|concert:\(concert.id)"

            let data: [String: Any] = [
                "concertId": concert.id,
                "registerDate": Timestamp(date: self.ticketDate),
                "userEmail": email,
                "qrData": self.ticketQR
            ]

            docRef.setData(data) { error in
                if error == nil {
                    self.showSuccessAlert = true
                } else {
                    // ถ้าต้องการ แจ้ง error เพิ่มเติมได้
                }
            }
        }
    }

    private func mapsURL(for place: String) -> URL? {
        let query = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://maps.apple.com/?q=\(query)")
    }
}

#Preview {
    NavigationStack {
        let sample = Homeview.Concert(
            id: "sample-id",
            title: "Sample Concert",
            subtitle: "Live in Bangkok",
            date: "2025-12-31",
            time: "20:00",
            location: "Sample Arena",
            imageURL: "https://picsum.photos/800/600",
            detail: "This is a sample concert used for previews.",
            mapURL: "http://maps.apple.com/?q=Sample%20Arena"
        )
        ConcertDetailView(concert: sample)
    }
}

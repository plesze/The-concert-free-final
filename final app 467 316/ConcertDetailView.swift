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

    // แจ้งเตือน “ลงทะเบียนซ้ำ” หรือ “เต็มแล้ว”
    @State private var showAlreadyRegisteredAlert = false

    // จำนวนผู้ลงทะเบียนแบบเรียลไทม์ + ตัวอัปเดตข้อมูลเรียลไทม์
    @State private var registeredCount: Int = 0
    @State private var ticketsListener: ListenerRegistration?
    var isFull: Bool { registeredCount >= concert.maxSeats }

    // สถานะว่าผู้ใช้คนนี้ “ได้ลงทะเบียนคอนเสิร์ตนี้แล้ว” หรือยัง
    @State private var isRegistered: Bool = false
    @State private var myTicketListener: ListenerRegistration?

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

                        VStack(alignment: .leading, spacing: 6) {
                            Text(concert.title)
                                .font(.title2).fontWeight(.black)
                                .foregroundColor(.primary)

                            Text(concert.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar").foregroundColor(.green)
                                Text(concert.date)
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "clock").foregroundColor(.green)
                                Text(concert.time)
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "person.fill").foregroundColor(.green)
                                Text("Seats: \(concert.maxSeats)  |  Registered: \(registeredCount)")
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)

                            Text(concert.location)
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .layoutPriority(0)

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
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Capsule().fill(Color.blue.opacity(0.9)))
                            }
                            .buttonStyle(.plain)
                            .layoutPriority(1)
                        }
                        .padding(.horizontal, 4)

                        Text(concert.detail)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 6)

                        Button {
                            if Auth.auth().currentUser == nil {
                                showLoginAlert = true
                            } else {
                                registerTicket()
                            }
                        } label: {
                            Text(isRegistered ? "ลงทะเบียนแล้ว" : (isFull ? "เต็มแล้ว" : "ลงทะเบียน"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule().fill((isRegistered || isFull) ? Color.gray : Color.red)
                                )
                        }
                        .disabled(isRegistered || isFull)
                        .padding(.top, 8)
                        .shadow(color: ((isRegistered || isFull) ? Color.gray : Color.red).opacity(0.35), radius: 5, x: 0, y: 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
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

            .alert("ไม่สามารถลงทะเบียนได้", isPresented: $showAlreadyRegisteredAlert) {
                Button("ตกลง", role: .cancel) { }
            } message: {
                Text(isFull ? "คอนเสิร์ตนี้เต็มแล้ว" : "คุณลงทะเบียนคอนเสิร์ตนี้ไปแล้ว")
            }

            .navigationDestination(isPresented: $navigateToLogin) {
                Loginpage(selectedTab: .constant(2))
            }

            .navigationDestination(isPresented: $navigateToTicket) {
                TicketDetailView(concert: concert, qrString: ticketQR, registerDate: ticketDate)
            }

            .onAppear {
                attachTicketsListener()
                attachMyTicketListener()
            }
            .onDisappear {
                detachTicketsListener()
                detachMyTicketListener()
            }
        }
    }

    private func registerTicket() {
        guard let user = Auth.auth().currentUser else { return }

        if isFull || isRegistered {
            self.showAlreadyRegisteredAlert = true
            return
        }

        let email = user.email ?? user.uid
        let uid = user.uid
        let db = Firestore.firestore()

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
                // เช็คจำนวนที่นั่งคงเหลือแบบเรียลไทม์อีกรอบ
                db.collection("tickets")
                    .whereField("concertId", isEqualTo: self.concert.id)
                    .getDocuments { snap2, _ in
                        let currentCount = snap2?.documents.count ?? 0
                        if currentCount >= self.concert.maxSeats {
                            self.showAlreadyRegisteredAlert = true
                            return
                        }
                        createTicket(for: email, uid: uid, db: db)
                    }
            }
    }

    private func createTicket(for email: String, uid: String, db: Firestore) {
        let fixedDocId = "\(uid)_\(concert.id)"
        let ticketRef = db.collection("tickets").document(fixedDocId)
        let concertRef = db.collection("concerts").document(concert.id)
        let userRef = db.collection("users").document(uid)

        // ดึง username จาก Firestore ก่อน (วิธี B)
        userRef.getDocument { userSnap, _ in
            let firestoreUsername = userSnap?.data()?["username"] as? String
            let authDisplayName = Auth.auth().currentUser?.displayName
            let username = firestoreUsername?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? firestoreUsername!
                : (authDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                   ? authDisplayName!
                   : "Unknown")

            // ใช้ธุรกรรมเพื่อ:
            // - อ่าน concerts.currentRegistered, maxSeats
            // - ตรวจไม่เต็ม
            // - เพิ่ม currentRegistered
            // - เขียน ticket พร้อม seatNumber
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                // อ่านคอนเสิร์ต
                let concertDoc: DocumentSnapshot
                do {
                    concertDoc = try transaction.getDocument(concertRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }

                guard let concertData = concertDoc.data() else {
                    errorPointer?.pointee = NSError(domain: "ConcertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Concert not found"])
                    return nil
                }

                let maxSeats = concertData["maxSeats"] as? Int ?? self.concert.maxSeats
                let currentRegistered = concertData["currentRegistered"] as? Int ?? 0

                // ตรวจว่าเต็มหรือยัง
                if currentRegistered >= maxSeats {
                    errorPointer?.pointee = NSError(domain: "ConcertError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Concert is full"])
                    return nil
                }

                // ที่นั่งถัดไป
                let nextSeatNumber = currentRegistered + 1
                let seatNumber = "\(nextSeatNumber)"

                // อัปเดตตัวนับ
                transaction.updateData(["currentRegistered": nextSeatNumber], forDocument: concertRef)

                // เตรียมข้อมูลตั๋ว
                let registerDate = Date()
                let qr = "user:\(email)|username:\(username)|seat:\(seatNumber)"
                let ticketData: [String: Any] = [
                    "concertId": self.concert.id,
                    "registerDate": Timestamp(date: registerDate),
                    "userEmail": email,
                    "username": username,
                    "seatNumber": seatNumber,
                    "qrData": qr
                ]

                // เขียนตั๋ว
                transaction.setData(ticketData, forDocument: ticketRef)

                // ส่งค่ากลับบางอย่างเพื่อใช้ใน completion (เก็บไว้ใน state)
                return ["registerDate": registerDate, "qr": qr] as [String: Any]
            }, completion: { result, error in
                if let error = error {
                    // ถ้าเต็มหรือซ้ำจะแจ้งเตือน
                    self.showAlreadyRegisteredAlert = true
                    return
                }

                if let dict = result as? [String: Any],
                   let date = dict["registerDate"] as? Date,
                   let qr = dict["qr"] as? String {
                    self.ticketDate = date
                    self.ticketQR = qr
                    self.showSuccessAlert = true
                } else {
                    // fallback เผื่อ transaction ไม่ส่งผลลัพธ์
                    self.ticketDate = Date()
                    self.ticketQR = "user:\(email)|username:\(username)|seat:A1"
                    self.showSuccessAlert = true
                }
            })
        }
    }

    private func attachTicketsListener() {
        let db = Firestore.firestore()
        // ติดตั้ง “ตัวอัปเดตข้อมูลเรียลไทม์” เพื่ออัปเดตจำนวนผู้ลงทะเบียนของงานนี้
        ticketsListener = db.collection("tickets")
            .whereField("concertId", isEqualTo: concert.id)
            .addSnapshotListener { snapshot, _ in
                self.registeredCount = snapshot?.documents.count ?? 0
            }
    }

    private func detachTicketsListener() {
        // ถอด “ตัวอัปเดตข้อมูลเรียลไทม์” ของจำนวนผู้ลงทะเบียน
        ticketsListener?.remove()
        ticketsListener = nil
    }

    private func attachMyTicketListener() {
        guard let user = Auth.auth().currentUser else {
            isRegistered = false
            return
        }
        let email = user.email ?? user.uid
        let db = Firestore.firestore()
        // ติดตั้ง “ตัวอัปเดตข้อมูลเรียลไทม์” เพื่อตรวจว่าผู้ใช้คนนี้มีตั๋วของงานนี้หรือยัง
        myTicketListener = db.collection("tickets")
            .whereField("concertId", isEqualTo: concert.id)
            .whereField("userEmail", isEqualTo: email)
            .addSnapshotListener { snapshot, _ in
                self.isRegistered = (snapshot?.documents.isEmpty == false)
            }
    }

    private func detachMyTicketListener() {
        // ถอด “ตัวอัปเดตข้อมูลเรียลไทม์” ของสถานะตั๋วผู้ใช้
        myTicketListener?.remove()
        myTicketListener = nil
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
            mapURL: "http://maps.apple.com/?q=Sample%20Arena",
            maxSeats: 1
        )
        ConcertDetailView(concert: sample)
    }
}

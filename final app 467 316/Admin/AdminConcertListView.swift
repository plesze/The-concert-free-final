import SwiftUI
import FirebaseFirestore

struct AdminConcertListView: View {
    struct Concert: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let date: String
        let time: String
        let location: String
        let imageURL: String
        let detail: String
        let mapURL: String
        let maxSeats: Int
        var registeredCount: Int = 0
    }

    @State private var concerts: [Concert] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteId: String?

    private let db = Firestore.firestore()
    // เก็บ “ตัวอัปเดตข้อมูลเรียลไทม์” ของแต่ละ concertId
    @State private var ticketListeners: [String: ListenerRegistration] = [:]

    var body: some View {
        List {
            if isLoading {
                HStack {
                    ProgressView().tint(.primary)
                    Text("กำลังโหลดคอนเสิร์ต...")
                        .foregroundColor(.secondary)
                }
            }

            if let errorMessage = errorMessage {
                VStack(spacing: 8) {
                    Text("โหลดไม่สำเร็จ")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        loadConcerts()
                    } label: {
                        Label("ลองใหม่", systemImage: "arrow.clockwise")
                    }
                }
                .padding(.vertical, 8)
            }

            ForEach(concerts) { concert in
                NavigationLink {
                    AdminEditConcertView(concert: concert) { updated in
                        if let idx = concerts.firstIndex(where: { $0.id == updated.id }) {
                            concerts[idx] = updated
                            
                        } else {
                            concerts.append(updated)
                            attachTicketListener(for: updated.id)
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(concert.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(concert.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        HStack(spacing: 10) {
                            Label(concert.date, systemImage: "calendar")
                                .foregroundColor(.green)
                            Label(concert.time, systemImage: "clock")
                                .foregroundColor(.green)
                        }
                        .font(.footnote)

                        HStack(spacing: 6) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                            Text("\(concert.registeredCount) / \(concert.maxSeats)")
                                .foregroundColor(concert.registeredCount >= concert.maxSeats ? .red : .primary)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        pendingDeleteId = concert.id
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Manage Concerts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AdminEditConcertView(concert: nil) { created in
                        concerts.append(created)
                        attachTicketListener(for: created.id)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .onAppear {
            loadConcerts()
        }
        .onDisappear {
            detachAllTicketListeners()
        }
        .alert("ลบคอนเสิร์ตนี้?", isPresented: $showDeleteConfirm) {
            Button("ยกเลิก", role: .cancel) { pendingDeleteId = nil }
            Button("ลบ", role: .destructive) {
                if let id = pendingDeleteId {
                    deleteConcert(id: id)
                }
            }
        } message: {
            Text("การลบจะเอาออกจาก Firestore ทันที")
        }
    }

    private func loadConcerts() {
        isLoading = true
        errorMessage = nil
        detachAllTicketListeners() // รีเซ็ตตัวอัปเดตข้อมูลเรียลไทมเดิมก่อนโหลดใหม่

        db.collection("concerts").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            let docs = snapshot?.documents ?? []
            let items: [Concert] = docs.compactMap { doc in
                let data = doc.data()
                guard
                    let title = data["title"] as? String,
                    let subtitle = data["subtitle"] as? String,
                    let date = data["date"] as? String,
                    let time = data["time"] as? String,
                    let location = data["location"] as? String,
                    let detail = data["detail"] as? String,
                    let imageURL = data["imageURL"] as? String,
                    let mapURL = data["mapURL"] as? String,
                    let maxSeats = data["maxSeats"] as? Int
                else { return nil }
                return Concert(
                    id: doc.documentID,
                    title: title,
                    subtitle: subtitle,
                    date: date,
                    time: time,
                    location: location,
                    imageURL: imageURL,
                    detail: detail,
                    mapURL: mapURL,
                    maxSeats: maxSeats,
                    registeredCount: 0
                )
            }

            self.concerts = items

            // แนบตัวอัปเดตข้อมูลเรียลไทม์ให้ทุกคอนเสิร์ต เพื่ออัปเดต registeredCount
            for c in items {
                attachTicketListener(for: c.id)
            }
        }
    }

    private func attachTicketListener(for concertId: String) {
        // ป้องกันแนบอัปเดตข้อมูลเรียลไทม์ซ้ำ
        if ticketListeners[concertId] != nil { return }

        let listener = db.collection("tickets")
            .whereField("concertId", isEqualTo: concertId)
            .addSnapshotListener { snapshot, _ in
                let count = snapshot?.documents.count ?? 0
                if let idx = self.concerts.firstIndex(where: { $0.id == concertId }) {
                    self.concerts[idx].registeredCount = count
                }
            }

        ticketListeners[concertId] = listener
    }

    private func detachAllTicketListeners() {
        for (_, l) in ticketListeners {
            l.remove()
        }
        ticketListeners.removeAll()
    }

    private func deleteConcert(id: String) {
        // ถอดตัวอัปเดตข้อมูลเรียลไทม์ของงานนี้ก่อนลบ
        if let l = ticketListeners[id] {
            l.remove()
            ticketListeners[id] = nil
        }
        db.collection("concerts").document(id).delete { error in
            if let error = error {
                errorMessage = "ลบไม่สำเร็จ: \(error.localizedDescription)"
                return
            }
            concerts.removeAll { $0.id == id }
        }
    }
}

//
//  TicketView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 18/11/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TicketView: View {
    struct TicketItem: Identifiable {
        let id: String                 // id ของเอกสาร ticket
        let concert: Homeview.Concert  // รายละเอียดคอนเสิร์ตที่โหลดมา
        let qrString: String           // ข้อความสำหรับสร้าง QR
        let registerDate: Date         // วันที่ลงทะเบียน
    }

    // เก็บตั๋วทั้งหมดของฉัน
    @State private var myTickets: [TicketItem] = []

    // สถานะโหลด/ข้อผิดพลาด
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView().tint(.primary)
                        Text("กำลังโหลดตั๋วของคุณ...")
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 12) {
                        Text("โหลดตั๋วไม่สำเร็จ")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button {
                            loadMyTickets()
                        } label: {
                            Label("ลองใหม่", systemImage: "arrow.clockwise")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.primary.opacity(0.15)))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.primary)
                    }
                    .padding()
                } else if myTickets.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "ticket")
                            .foregroundColor(.secondary)
                            .font(.system(size: 36, weight: .bold))
                        Text("ยังไม่มีตั๋ว")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("ลงทะเบียนคอนเสิร์ตก่อน ตั๋วของคุณจะมาขึ้นที่นี่")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(myTickets) { item in
                            NavigationLink {
                                TicketDetailView(
                                    concert: item.concert,
                                    qrString: item.qrString,
                                    registerDate: item.registerDate
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.concert.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(item.concert.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)

                                    HStack(spacing: 12) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.green)
                                            Text(item.concert.date)
                                                .foregroundColor(.green)
                                                .font(.subheadline)
                                        }
                                        HStack(spacing: 6) {
                                            Image(systemName: "clock")
                                                .foregroundColor(.green)
                                            Text(item.concert.time)
                                                .foregroundColor(.primary)
                                                .font(.subheadline)
                                        }
                                    }

                                    Text("ลงทะเบียนเมื่อ: \(item.registerDate.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("ตั๋วของฉัน")
        }
        .onAppear {
            loadMyTickets()
        }
    }

    private func loadMyTickets() {
        isLoading = true
        errorMessage = nil
        myTickets = []

        guard let user = Auth.auth().currentUser else {
            isLoading = false
            errorMessage = "กรุณาเข้าสู่ระบบก่อน"
            return
        }
        let email = user.email ?? user.uid
        let db = Firestore.firestore()

        db.collection("tickets")
            .whereField("userEmail", isEqualTo: email)
            .order(by: "registerDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                let docs = snapshot?.documents ?? []
                if docs.isEmpty {
                    self.isLoading = false
                    self.myTickets = []
                    return
                }

                let group = DispatchGroup()
                var results: [TicketItem] = []

                for doc in docs {
                    let data = doc.data()
                    let ticketId = doc.documentID
                    let concertId = data["concertId"] as? String ?? ""
                    let qrData = data["qrData"] as? String ?? ""
                    let registerTS = data["registerDate"] as? Timestamp
                    let registerDate = registerTS?.dateValue() ?? Date()
                    let ticketType = data["ticketType"] as? String ?? "regular"

                    if concertId.isEmpty { continue }

                    group.enter()
                    db.collection("concerts").document(concertId).getDocument { snap, _ in
                        defer { group.leave() }

                        guard let snap, snap.exists, let cdata = snap.data(),
                              let title = cdata["title"] as? String,
                              let subtitle = cdata["subtitle"] as? String,
                              let date = cdata["date"] as? String,
                              let time = cdata["time"] as? String,
                              let location = cdata["location"] as? String,
                              let detail = cdata["detail"] as? String,
                              let imageURL = cdata["imageURL"] as? String,
                              let mapURL = cdata["mapURL"] as? String,
                              let maxSeats = cdata["maxSeats"] as? Int
                        else { return }

                        let concert = Homeview.Concert(
                            id: snap.documentID,
                            title: title,
                            subtitle: subtitle,
                            date: date,
                            time: time,
                            location: location,
                            imageURL: imageURL,
                            detail: detail,
                            mapURL: mapURL,
                            maxSeats: maxSeats
                        )

                        let item = TicketItem(
                            id: ticketId,
                            concert: concert,
                            qrString: qrData,
                            registerDate: registerDate
                        )
                        results.append(item)
                    }
                }

                group.notify(queue: .main) {
                    self.myTickets = results
                    self.isLoading = false
                }
            }
    }
}

#Preview {
    TicketView()
}

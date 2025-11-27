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

var body: some View {
    NavigationStack {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Load remote image from URL string
                    AsyncImage(url: URL(string: concert.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                                    .tint(.primary)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.2)
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            }
                        @unknown default:
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(concert.title)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                    
                    Text(concert.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        Text(concert.date)
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                        Text(concert.time)
                            .foregroundColor(.primary)
                            .font(.subheadline)
                    }
                    
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(concert.location)
                                .foregroundColor(.blue)
                                .font(.subheadline)
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
                    
                    Text(concert.detail)
                        .foregroundColor(.primary)
                    
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
        
        // Alert สำหรับลงทะเบียนสำเร็จ
        .alert("ลงทะเบียนเข้าร่วมสำเร็จ", isPresented: $showSuccessAlert) {
            Button("เข้าใจแล้ว", role: .cancel) {
                navigateToTicket = true
            }
        } message: {
            Text("แล้วเจอกันในงาน \(concert.title) !")
        }
        
        // Alert สำหรับ login
        .alert("กรุณาเข้าสู่ระบบก่อนลงทะเบียน", isPresented: $showLoginAlert) {
            Button("เข้าสู่ระบบ") {
                navigateToLogin = true
            }
        }
        
        // NavigationDestination สำหรับ login
        .navigationDestination(isPresented: $navigateToLogin) {
            Loginpage(selectedTab: .constant(2))
        }
        
        // NavigationDestination สำหรับ TicketDetailView
        .navigationDestination(isPresented: $navigateToTicket) {
            TicketDetailView(
                concert: concert,
                qrString: ticketQR,
                registerDate: ticketDate
            )
        }
    }
}

// ฟังก์ชันเพิ่มตั๋วลง Firestore
private func registerTicket() {
    guard let user = Auth.auth().currentUser else {
        return
    }
    let email = user.email ?? user.uid
    
    let db = Firestore.firestore()
    let ticketRef = db.collection("tickets").document()
    let ticketId = ticketRef.documentID
    
    ticketQR = "ticket:\(ticketId)|user:\(email)|concert:\(concert.id)"
    ticketDate = Date()
    
    let ticketData: [String: Any] = [
        "concertId": concert.id,
        "registerDate": Timestamp(date: ticketDate),
        "userEmail": email,
        "qrData": ticketQR
    ]
    
    db.collection("tickets")
        .addDocument(data: ticketData) { error in
            if error == nil {
                showSuccessAlert = true
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

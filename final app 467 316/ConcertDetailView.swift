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
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Load remote image from URL string
                    AsyncImage(url: URL(string: concert.imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                                    .tint(.white)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.gray.opacity(0.2)
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
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
                        .foregroundColor(.white)
                    
                    Text(concert.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
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
                            .foregroundColor(.white)
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
                        .foregroundColor(.white)
                    
                    Button {
                        print("Register button tapped")
                        if Auth.auth().currentUser == nil {
                            print("No current user -> showLoginAlert")
                            showLoginAlert = true
                        } else {
                            print("User exists -> call registerTicket()")
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
                print("Success alert dismissed -> navigate to Ticket")
                navigateToTicket = true
            }
        } message: {
            Text("แล้วเจอกันในงาน \(concert.title) !")
        }
        
        // Alert สำหรับ login
        .alert("กรุณาเข้าสู่ระบบก่อนลงทะเบียน", isPresented: $showLoginAlert) {
            Button("เข้าสู่ระบบ") {
                print("Go to Login tapped")
                navigateToLogin = true
            }
        }
        
        // NavigationDestination สำหรับ login
        .navigationDestination(isPresented: $navigateToLogin) {
            Loginpage(selectedTab: .constant(2))
        }
        
        // NavigationDestination สำหรับ TicketDetailView
        .navigationDestination(isPresented: $navigateToTicket) {
            print("Navigate to TicketDetailView with qrString=\(ticketQR)")
            return TicketDetailView(
                concert: concert,
                qrString: ticketQR,
                registerDate: ticketDate
            )
        }
    }
}

// ฟังก์ชันเพิ่มตั๋วลง Firestore
private func registerTicket() {
    print("registerTicket() called")
    guard let user = Auth.auth().currentUser else {
        print("No user in registerTicket()")
        return
    }
    let email = user.email ?? user.uid
    print("Using email/uid: \(email)")
    
    let db = Firestore.firestore()
    let ticketRef = db.collection("tickets").document()
    let ticketId = ticketRef.documentID
    
    // concert.id is String, use it directly
    ticketQR = "ticket:\(ticketId)|user:\(email)|concert:\(concert.id)"
    ticketDate = Date()
    print("Prepared data, qr=\(ticketQR)")
    
    let ticketData: [String: Any] = [
        "concertId": concert.id,
        "registerDate": Timestamp(date: ticketDate),
        "userEmail": email,
        "qrData": ticketQR
    ]
    
    print("Writing ticket to Firestore...")
    db.collection("tickets")
        .addDocument(data: ticketData) { error in
            if let error = error {
                print("Error adding ticket: \(error.localizedDescription)")
            } else {
                print("Ticket added successfully -> showSuccessAlert = true")
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
    //ข้อมูบจำลองอเพื่อให้ swiftui preveiw ทำงานได้
}
}

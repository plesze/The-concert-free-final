import SwiftUI
import FirebaseAuth

struct ConcertDetailView: View {
    let concert: Homeview.Concert
    @State private var showSuccessAlert = false
    @State private var navigateToLogin = false
    @State private var showLoginAlert = false
    @Environment(\.openURL) private var openURL
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(concert.imageName)
                        .resizable()
                        .scaledToFill()
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
                        Text(concert.dateText)
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                        Text(concert.timeText)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }

                    // แถวสถานที่ + ปุ่มเปิดแผนที่
                    HStack(alignment: .center, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(concert.locationText)
                                .foregroundColor(.blue)
                                .font(.subheadline)
                        }

                        Spacer(minLength: 8)

                        Button {
                            if let url = concert.mapURL {
                                openURL(url)
                            } else if let url = mapsURL(for: concert.locationText) {
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
                        if Auth.auth().currentUser == nil {
                            showLoginAlert = true
                        } else {
                            showSuccessAlert = true
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
                    .accessibilityLabel("Register for concert")
                }
                .padding()
                .navigationTitle("รายละเอียดคอนเสิร์ต")
                .navigationBarTitleDisplayMode(.inline)
                .alert("ลงทะเบียนเข้าร่วมสำเร็จ", isPresented: $showSuccessAlert) {
                    Button("เข้าใจแล้ว", role: .cancel) { }
                } message: {
                    Text("แล้วเจอกันในงาน \(concert.title) !")
                }
                .alert("กรุณาเข้าสู่ระบบก่อนลงทะเบียน", isPresented: $showLoginAlert) {
                    Button("เข้าสู่ระบบ") {
                        navigateToLogin = true
                    }
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    Loginpage(selectedTab: .constant(2))
                }
            }
        }
    }

    // fallback เมื่อไม่มี mapURL
    private func mapsURL(for place: String) -> URL? {
        let query = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://maps.apple.com/?q=\(query)")
    }
}

#Preview {
    NavigationStack {
        ConcertDetailView(concert: Homeview.sampleConcerts.first!)
    }
}


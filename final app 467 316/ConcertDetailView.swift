import SwiftUI

struct ConcertDetailView: View {
    let concert: Homeview.Concert
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(concert.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(concert.title)
                    .font(.title2)
                    .fontWeight(.bold)
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
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                    Text(concert.locationText)
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                HStack(spacing: 8){
                    Text(concert.detail)
                        .foregroundColor(.white)
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("รายละเอียดคอนเสิร์ต")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ConcertDetailView(concert: Homeview.sampleConcerts.first!)
}

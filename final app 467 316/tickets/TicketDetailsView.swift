//
//  TicketDetailsView.swift
//  final app 467 316
//
//  Created by Yamada Bingus on 20/11/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreImage.CIFilterBuiltins

struct TicketDetailView: View {
    // Properties
    let concert: Homeview.Concert
    let qrString: String
    let registerDate: Date
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    // Init with default values for Preview
    init(
        concert: Homeview.Concert = Homeview.Concert(
            id: "sample-id",
            title: "Sample Concert",
            subtitle: "Live in Bangkok",
            date: "2025-12-31",
            time: "20:00",
            location: "Sample Arena",
            imageURL: "https://example.com/sample.jpg",
            detail: "This is a sample concert used for previews.",
            mapURL: "http://maps.apple.com/?q=Sample%20Arena",
            maxSeats: 1
        ),
        qrString: String = "user:preview@example.com|username:Cloud|seat:A1",
        registerDate: Date = Date()
    ) {
        self.concert = concert
        self.qrString = qrString
        self.registerDate = registerDate
    }
    
    // Body
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                // Card container (กรอบเทาจะปรับสูงตามเนื้อหา)
                ticketCardView
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .frame(maxWidth: 380) // คุมความกว้างได้ แต่ปล่อยความสูงตามเนื้อหา
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("E-Ticket")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Ticket Card View
    var ticketCardView: some View {
        let info = parseQR(qrString)
        
        return VStack(alignment: .center, spacing: 10) {
            
            Text(concert.title)
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            Text(concert.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider().frame(maxWidth: .infinity)
            
            Image(uiImage: generateQR(from: qrString))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.vertical, 15)
            
            Divider().frame(maxWidth: .infinity)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                
                HStack {
                    Text("Seat No.:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(info["seat"] ?? "-")
                        .bold()
                }
                
                HStack {
                    Text("Event Time:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(concert.date) •")
                        .bold()
                }
                
                VStack {
                    Text("\(concert.time)")
                        .bold()
                }
                
                HStack {
                    Text("Location:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(concert.location)
                        .bold()
                }
            }
            .frame(maxWidth: 340) // คุมความกว้าง ไม่ล็อกความสูง
        }
        .padding()
    }
    
    // Parse QR text
    func parseQR(_ qr: String) -> [String: String] {
        var dict: [String: String] = [:]
        
        let parts = qr.split(separator: "|")
        for part in parts {
            let kv = part.split(separator: ":", maxSplits: 1)
            if kv.count == 2 {
                dict[String(kv[0])] = String(kv[1])
            }
        }
        
        return dict
    }
    
    // QR Code Generator
    func generateQR(from string: String, size: CGFloat = 200) -> UIImage {
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let scale = size / outputImage.extent.size.width
        let transformedImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: scale, y: scale)
        )
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    NavigationStack {
        TicketDetailView()
    }
}

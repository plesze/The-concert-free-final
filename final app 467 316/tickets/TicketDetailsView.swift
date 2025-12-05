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
    //Properties
    let concert: Homeview.Concert
    let qrString: String
    let registerDate: Date
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @State private var hasScannedQR = false     // สแกนเสร็จ (มาจากหน้า Scan)
    @State private var isCheckedIn = false      // กดเช็กอินแล้ว
    @State private var showCheckinAlert = false // alert
    
    //Init with default values for Preview
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
        qrString: String = "ticket:previewTicket|user:preview@example.com|concert:sample",
        registerDate: Date = Date()
    ) {
        self.concert = concert
        self.qrString = qrString
        self.registerDate = registerDate
    }
    
    //Body
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                // Card container
                ZStack {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .frame(maxWidth: 380, maxHeight: 510)
                    
                    ticketCardView
                        .padding()
                }
                
                // MARK: - ปุ่มเช็กอิน (เทา → แดง → เขียว)
                VStack(spacing: 10) {
                    
                    // ปุ่มเทา (ยังไม่สแกน)
                    if hasScannedQR == false {
                        Button {} label: {
                            Text("กรุณาสแกน QR ก่อน")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.gray)
                                .cornerRadius(12)
                        }
                        .frame(width: 380)
                        .disabled(true)
                        
                    } else {
                        // ปุ่มแดง → เขียว หลังสแกน
                        Button {
                            checkInToEvent()
                        } label: {
                            Text(isCheckedIn ? "เข้างานแล้ว" : "ยืนยันว่าเข้างานแล้ว")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isCheckedIn ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .frame(width: 380)
                        .disabled(isCheckedIn)
                    }
                }
                .padding(.top, 10)
                .alert("เช็กอินสำเร็จ!", isPresented: $showCheckinAlert) {
                    Button("OK", role: .cancel) { }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("E-Ticket")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //Ticket Card View
    var ticketCardView: some View {
        VStack(alignment: .center, spacing: 10) {
            
            Text(concert.title)
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            Text(concert.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
                .frame(width: 380)
            
            Image(uiImage: generateQR(from: qrString))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.vertical, 15)
            
            Divider()
                .frame(width: 380)
            
            VStack(alignment: .trailing, spacing: 12) {
                HStack {
                    Text("Event Time:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(concert.date) • \(concert.time)")
                        .bold()
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    Text("Location:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(concert.location)
                        .bold()
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 340, height: 100)
        }
    }
    
    //QR Code Generator
    func generateQR(from string: String, size: CGFloat = 200) -> UIImage {
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let scale = size / outputImage.extent.size.width
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - เช็กอิน (หลังสแกน)
    func checkInToEvent() {
        guard hasScannedQR else { return }
        
        isCheckedIn = true
        showCheckinAlert = true
    }
    
}

//Preview
#Preview {
    NavigationStack {
        TicketDetailView()
    }
}




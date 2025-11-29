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
    // MARK: - Properties
    let concert: Homeview.Concert
    let qrString: String
    let registerDate: Date

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    @State private var showSavedAlert = false

    // MARK: - Init with default values for Preview
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

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ticketCardView
                .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
        .navigationTitle("ตั๋วของคุณ")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Saved!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: - Ticket Card View
    var ticketCardView: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(.systemBackground))
            .shadow(radius: 4)
            .overlay(
                VStack(spacing: 16) {

                    // Concert Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(concert.title)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Text(concert.location)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    // QR Code
                    Image(uiImage: generateQR(from: qrString))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.vertical, 12)

                    Divider()

                    // Detail Section
                    VStack(alignment: .leading, spacing: 12) {

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
                    .padding(.horizontal, 6)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            )
    }

    // MARK: - Save Button
    var saveButton: some View {
        Button {
            saveTicketAsImage()
        } label: {
            Label("Save as image", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent) // ใช้ accent/tint ของระบบอัตโนมัติ
        .tint(.accentColor)              // ให้ตามธีม/Accent ที่ผู้ใช้เลือก
        .padding(.bottom, 8)
    }

    // MARK: - QR Code Generator
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

    // MARK: - Save Ticket
    func saveTicketAsImage() {
        let renderer = ImageRenderer(content: ticketCardView)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            showSavedAlert = true
        }
    }

}

// MARK: - Preview
#Preview {
    NavigationStack {
        TicketDetailView()
    }
}

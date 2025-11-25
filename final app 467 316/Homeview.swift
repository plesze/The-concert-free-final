//
//  Homeview.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 17/11/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct Homeview: View {
    
    // MARK: - Model
    struct Concert: Identifiable {
        let id: String            // ใช้ documentID จาก Firestore
        let title: String
        let subtitle: String
        let date: String
        let time: String
        let location: String
        let imageURL: String
        let detail: String
        let mapURL: String
    }
    
    // MARK: - ViewModel (โหลดจาก Firestore)
    @StateObject private var viewModel = ViewModel()
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .tint(.white)
                        Text("กำลังโหลดคอนเสิร์ต...")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                } else if let error = viewModel.lastError {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                            .font(.system(size: 36, weight: .bold))
                        Text("โหลดข้อมูลไม่สำเร็จ")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(error)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button {
                            Task { await viewModel.loadConcerts() }
                        } label: {
                            Label("ลองใหม่", systemImage: "arrow.clockwise")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white.opacity(0.15)))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    }
                    .padding()
                } else if viewModel.concerts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "music.quarternote.3")
                            .foregroundColor(.white)
                            .font(.system(size: 36, weight: .bold))
                        Text("ยังไม่มีคอนเสิร์ต")
                            .foregroundColor(.white)
                            .font(.headline)
                        Text("โปรดกลับมาใหม่ภายหลัง")
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else {
                    content(concerts: viewModel.concerts)
                }
            }
        }
        .task {
            await viewModel.loadConcerts()
        }
    }
    
    // แยกส่วน UI หลักเมื่อมีข้อมูล
    @ViewBuilder
    private func content(concerts: [Concert]) -> some View {
        VStack {
            Spacer()
            
            TabView(selection: $currentIndex) {
                ForEach(concerts.indices, id: \.self) { index in
                    let concert = concerts[index]
                    
                    VStack(spacing: 0) {
                        // โหลดรูปจาก URL
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
                        .frame(height: 320)
                        .frame(width: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 1))
                        
                        Spacer().frame(height: 0)
                        
                        NavigationLink {
                            ConcertDetailView(concert: concert)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(concert.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(concert.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.green)
                                    Text(concert.date)
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.green)
                                    Text(concert.time)
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.blue)
                                    Text(concert.location)
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .padding(20)
                            .frame(width: 280, height: 170)
                            .background(
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.gray.opacity(0.5))
                            )
                            .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.top, 2)
                    }
                    .padding(.horizontal)
                    .tag(index)
                }
            }
            .frame(height: 560)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 8) {
                ForEach(concerts.indices, id: \.self) { index in
                    Circle()
                        .frame(
                            width: currentIndex == index ? 10 : 6,
                            height: currentIndex == index ? 10 : 6
                        )
                        .foregroundStyle(
                            currentIndex == index
                            ? Color.white
                            : Color.white.opacity(0.4)
                        )
                        .animation(.spring(duration: 0.2), value: currentIndex)
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

// MARK: - ViewModel
extension Homeview {
    final class ViewModel: ObservableObject {
        @Published var concerts: [Concert] = []
        @Published var isLoading: Bool = false
        @Published var lastError: String?
        
        private let db = Firestore.firestore()
        
        @MainActor
        func loadConcerts() async {
            isLoading = true
            lastError = nil
            do {
                let snapshot = try await db.collection("concerts").getDocuments()
                let items: [Concert] = snapshot.documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                        let subtitle = data["subtitle"] as? String,
                        let date = data["date"] as? String,
                        let time = data["time"] as? String,
                        let location = data["location"] as? String,
                        let detail = data["detail"] as? String,
                        let imageURL = data["imageURL"] as? String,
                        let mapURL = data["mapURL"] as? String
                    else {
                        return nil
                    }
                    return Concert(
                        id: doc.documentID,
                        title: title,
                        subtitle: subtitle,
                        date: date,
                        time: time,
                        location: location,
                        imageURL: imageURL,
                        detail: detail,
                        mapURL: mapURL
                    )
                }
                self.concerts = items
            } catch {
                self.lastError = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    Homeview()
}

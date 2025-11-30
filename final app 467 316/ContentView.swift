//
//  ContentView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 17/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ===== TOP BAR =====
                HStack {
                    Text("The Concert Free")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // ===== TAB BAR + VIEWS =====
                TabView {
                    Tab(constants.homeString, systemImage: constants.homeicon) {
                        Homeview()
                    }
                    Tab(constants.ticket, systemImage: constants.ticketicon) {
                        TicketView()
                    }

                    // เพิ่มแท็บ Admin เฉพาะตอนเป็นแอดมิน
                    if auth.role == "admin" {
                        Tab("Admin", systemImage: "shield.lefthalf.filled") {
                            adminView()
                        }
                    }

                    Tab(constants.profile, systemImage: constants.profileicon) {
                        ProflieView(selectedTab: $selectedTab)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    // สำคัญ: ต้องฉีด EnvironmentObject ให้ Preview ด้วย
    ContentView()
        .environmentObject(AuthViewModel())
}

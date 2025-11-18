//
//  ContentView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 17/11/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ===== TOP BAR =====
                HStack {
                    Text("The Concert Free")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(Color.black)
                
                Divider()
                    .background(Color.white.opacity(10))
                
                // ===== TAB BAR + VIEWS =====
                TabView {
                    Tab(constants.homeString, systemImage: constants.homeicon) {
                        Homeview()
                    }
                    Tab(constants.ticket, systemImage: constants.ticketicon) {
                        TicketView()
                    }
                    Tab(constants.profile, systemImage: constants.profileicon) {
                        Text("Profile")
                    }
                }
            }
            .background(Color.black)
        }
    }
}

#Preview {
    ContentView()
}

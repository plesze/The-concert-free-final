//
//  adminView.swift
//  final app 467 316
//
//  Created by Varagorn Lapachai on 30/11/2568 BE.
//

import SwiftUI

struct adminView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Admin Tools") {
                    NavigationLink("Manage Concerts") {
                        AdminConcertListView()
                    }
                    NavigationLink("Add Concert") {
                        AdminEditConcertView(concert: nil) { _ in }
                    }
                }
            }
            .navigationTitle("Admin")
        }
    }
}

#Preview {
    adminView()
}

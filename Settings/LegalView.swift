//
//  LegalView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 31/08/26.
//
//  A SwiftUI view that displays the legal notice.

import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            Text(notice())
                .bold()
        }
        .padding(Design.Padding.standard * 1.89)
        .navigationTitle("Legal Notice")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func notice() -> String {
        if let url = Bundle.main.url(forResource: "LICENSE", withExtension: "") {
            do {
                let data = try Data(contentsOf: url)
                let content = String(data: data, encoding: .utf8)
                return content ?? ""
            } catch {
                print("Error decoding license data. \(error.localizedDescription)")
            }
        }
        return ""
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
}

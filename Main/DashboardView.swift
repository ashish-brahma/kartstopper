//
//  DashboardView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var showPreferences: Bool
    
    let reader: GeometryProxy
    
    var body: some View {
        List {
            Section {
                StatusCardView(reader: reader,
                               viewModel: viewModel)
            }
            
            if !viewModel.hasOnboarded {
                Section {
                    SetupView(showPreferences: $showPreferences)
                } header: {
                    Text("Complete Setup")
                }
                .listRowBackground(Color.cardLabel)
            }
            
            Section {
                listsCard(reader: reader)
            } header: {
                Text(viewModel.totalCarts == 0 ? "Start Listing" : "Continue Listing")
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func listsCard(reader: GeometryProxy) -> some View {
        NavigationLink {
            CartListView(viewModel: viewModel)
        } label: {
            CardLabelView(title: "Carts",
                          stat: "\(viewModel.totalCarts)",
                          description: "Total Carts",
                          reader: reader,
                          content: TopCarts())
        }
    }
}

#Preview {
    GeometryReader { reader in
        NavigationStack {
            DashboardView(viewModel: .preview,
                          showPreferences: .constant(false),
                          reader: reader)
            .background(Color.background)
        }
    }
}

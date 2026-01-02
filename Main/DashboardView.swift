//
//  DashboardView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//
//  A SwiftUI view which displays the navigation list.

import SwiftUI
import CoreData

struct DashboardView: View {
    @ObservedObject var viewModel: ViewModel
    
    @Binding var showPreferences: Bool
    let reader: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var body: some View {
        List {
            if !viewModel.hasOnboarded {
                Section {
                    SetupView(showPreferences: $showPreferences)
                }
                .listRowBackground(Rectangle().fill(.thickMaterial))
            }
            
            Section {
                StatusCardView(reader: reader,
                               viewModel: viewModel)
            }
            
            Section {
                listsCard()
                
                NavigationLink {
                    CartListView(viewModel: viewModel)
                } label: {
                    Text(viewModel.totalCarts == 0 ? "Start Listing" : "Continue Listing")
                }
            }
            
            Section {
                expensesCard()
                
                NavigationLink {
                    // FIXME: Replace with detailed chart
                    Text("Last 7 days expenditure details")
                } label: {
                    Text("View Details")
                }
            }
            
            Section {
                TopCarts()
            }
        }
        .scrollContentBackground(.hidden)
        .task {
            viewModel.update(context: viewContext)
        }
    }
    
    @ViewBuilder
    private func listsCard() -> some View {
        VStack(alignment: .leading) {
            Text("Total Carts")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text("\(viewModel.totalCarts) Carts")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
        }
    }
    
    @ViewBuilder
    private func expensesCard() -> some View {
        VStack(alignment: .leading) {
            Text("Total Weekly Expenditure")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            // FIXME: Replace with correct data
            currencyLabel(for: viewModel.budget.totalMonthlySpend/4)
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            // FIXME: Replace with overview chart
            Text("Last 7 days expenditure overview")
        }
    }
    
    func currencyLabel(for amount: Double) -> some View {
        Text(amount, format: .currency(code: locale.currency?.identifier ?? "USD"))
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
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

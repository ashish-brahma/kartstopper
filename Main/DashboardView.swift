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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        GeometryReader { reader in
            List {
                if !viewModel.hasOnboarded {
                    Section {
                        SetupView(showPreferences: $showPreferences)
                    }
                    .listRowBackground(Rectangle().fill(.thickMaterial))
                }
                
                Section {
                    TopFrequentCarts(reader: reader)
                }
                
                Section {
                    StatusCardView(viewModel: viewModel)
                    
                    NavigationLink {
                        ExpenditureDetails()
                    } label: {
                        ExpenditureOverview(reader: reader)
                    }
                    
                    NavigationLink {
                        CategoryDetails()
                    } label: {
                        CategoriesOverview(reader: reader)
                    }
                } header: {
                    Text(viewModel.dynamicTitle)
                        .font(.title2.bold())
                        .foregroundStyle(viewModel.fontColor)
                }
            }
            .listRowSpacing(Design.Spacing.listRow)
            .navigationTitle("Track")
            .navigationTitleColor(Color.foreground)
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .task {
                viewModel.update(context: viewContext)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView(viewModel: .preview,
                      showPreferences: .constant(false))
        .background(Color.background)
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

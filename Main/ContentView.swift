//
//  ContentView.swift
//  kartstopper
//
//  Created by Ashish Brahma on 16/09/25.
//
//  A SwiftUI view that shows the main navigation UI.

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    @State private var showPreferences = false
    
    var body: some View {
        GeometryReader { reader in
            NavigationStack {
                ScrollView {
                    customNavbar(reader: reader)
                    
                    dashboard(reader: reader)
                }
                .navigationTitle("Home")
                .navigationTitleColor(Color.foreground)
                .background(Color.background)
                .toolbar(.hidden, for: .navigationBar)
            }
            .sheet(isPresented: $showPreferences,
                   onDismiss: {
                viewModel.update(context: viewContext)
            }) {
                NavigationStack {
                    ManageView(viewModel: viewModel)
                }
            }
            .task {
                viewModel.update(context: viewContext)
            }
        }
    }
    
    @ViewBuilder
    private func customNavbar(reader: GeometryProxy) -> some View {
        HStack {
            Text(viewModel.dynamicTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.fontColor)
                .padding(.leading, Design.Padding.leading/1.4)
            
            Spacer()
            
            settingsButton(reader: reader)
        }
        .padding(.top, reader.size.height/20)
        .padding(.horizontal, Design.Padding.horizontal)
        .padding(.bottom, -Design.Padding.bottom)
    }
    
    @ViewBuilder
    private func settingsButton(reader: GeometryProxy) -> some View {
        Button {
            showPreferences = true
        } label: {
            Label("Manage", systemImage: "gearshape.fill")
                .imageScale(.large)
                .labelStyle(.iconOnly)
        }
        .padding(Design.Padding.standard)
        .foregroundStyle(.accent)
        .clipShape(.capsule)
    }
    
    // MARK: - Dashboard methods
    
    @ViewBuilder
    private func dashboard(
        columns: [GridItem] = Array(repeating: GridItem(.flexible()),
                                    count: 2),
        reader: GeometryProxy
    ) -> some View {
        StatusCardView(reader: reader,
                           viewModel: viewModel)
        
        VStack {
            gridTitle()
            
            if !viewModel.hasOnboarded {
                setupView(reader: reader)
            }
            
            LazyVGrid(columns: columns) {
                gridCard(title: "Total Carts",
                         stat: "\(viewModel.totalCarts)",
                         content: CartListView(viewModel: viewModel),
                         reader: reader)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func gridTitle() -> some View {
        HStack {
            Text(viewModel.totalCarts == 0 ? "Start Listing" : "Continue Listing")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.foreground)
            
            Spacer()
        }
        .padding(.top, Design.Padding.top)
        .padding(.bottom, Design.Padding.bottom)
    }
    
    @ViewBuilder
    private func gridCard(
        title: String,
        stat: String,
        content: some View,
        reader: GeometryProxy
    ) -> some View {
        NavigationLink {
            content
        } label: {
            CardLabelView(title: title,
                          stat: stat,
                          detailIcon: "chevron.right.circle.fill",
                          reader: reader)
        }
    }
    
    // MARK: - Setup methods
    
    @ViewBuilder
    private func setupView(reader: GeometryProxy) -> some View {
        VStack {
            ContentView.unavailableView(label: "Create Budget",
                                        symbolName: "wrench.fill",
                                        description: "Budget amount would be used to track items marked as complete.")
            
            setupButton()
        }
        .padding()
        .background(.gray100)
        .clipShape(.rect(cornerRadius: 25))
        .padding(.vertical, Design.Padding.vertical)
    }
    
    @ViewBuilder
    private func setupButton() -> some View {
        Button {
            showPreferences = true
        } label: {
            Label("Setup", systemImage: "plus.circle.fill")
                .foregroundStyle(.gray300)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, -Design.Padding.top * 2)
        .padding(.bottom, Design.Padding.bottom)
    }
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

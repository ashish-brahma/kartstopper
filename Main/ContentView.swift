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
                VStack {
                    customNavbar(reader: reader)
                    dashboard(reader: reader)
                }
                .background(Color.background)
                .navigationTitle("Home")
                .navigationTitleColor(Color.foreground)
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
                .font(.title.bold())
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
    private func dashboard(reader: GeometryProxy) -> some View {
        List {
            Section {
                StatusCardView(reader: reader,
                               viewModel: viewModel)
            }
            .listRowBackground(Color.cardLabel.opacity(0.8))
            
            Section {
                if !viewModel.hasOnboarded {
                    setupView(reader: reader)
                }
            }
            .listRowBackground(Color.gray100)
            
            Section {
                listsCard(reader: reader)
            } header: {
                gridTitle()
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func listsCard(reader: GeometryProxy) -> some View {
        NavigationLink {
            CartListView(viewModel: viewModel)
        } label: {
            VStack {
                CardLabelView(title: "Carts",
                              stat: "\(viewModel.totalCarts)",
                              description: "Total Carts",
                              reader: reader)
                
                TopCarts()
            }
            .padding()
            .background(.cardLabel)
            .clipShape(.rect(cornerRadius: 25))
        }
    }
    
    @ViewBuilder
    private func gridTitle() -> some View {
        HStack {
            Text(viewModel.totalCarts == 0 ? "Start Listing" : "Continue Listing")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            Spacer()
        }
        .padding(.top, Design.Padding.top)
        .padding(.bottom, Design.Padding.bottom)
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

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
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { reader in
            NavigationStack {
                ScrollView {
                    title(reader: reader)
                    
                    statusCard(reader: reader)
                    
                    LazyVGrid(columns: columns) {
                        gridCard(title: "Total Carts",
                                 stat: "\(viewModel.totalCarts)",
                                 content: CartListView(viewModel: viewModel),
                                 reader: reader)
                    }
                    .padding(.horizontal, Design.Padding.horizontal * 2)
                }
                .navigationTitle("Home")
                .navigationTitleColor(Color.foreground)
                .background(Color.background)
                .toolbar(.hidden, for: .navigationBar)
                .toolbar {
                    dashboardToolbar()
                }
            }
            .sheet(isPresented: $showPreferences) {
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
    private func title(reader: GeometryProxy) -> some View {
        HStack {
            Text("\(viewModel.dynamicTitle)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .foregroundStyle(viewModel.fontColor)
                .padding(.leading, Design.Padding.leading)
                .padding(.bottom, -Design.Padding.bottom)
            
            Spacer()
        }
        .padding(.top, reader.size.height/20)
    }
    
    @ViewBuilder
    private func statusCard(reader: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text("This month you have spent")
                .font(Font.custom(Design.Fonts.italicCaption, size: 16))
                .padding(.top, reader.size.height/30)
                .padding(.leading, Design.Padding.leading)
                .position(x: reader.size.width/3.8,
                          y: reader.size.height/20)
                
            Text(viewModel.budget.totalMonthlySpend.formatted(.currency(code: locale.currency?.identifier ?? "USD")))
                .font(Font.custom(Design.Fonts.largeNumber, size: 80))
                .padding(.top, reader.size.height/20)
                .padding(.bottom, reader.size.height/10)
                .position(x: reader.size.width/2,
                          y: reader.size.height/20)
                
        }
        .frame(maxWidth: .infinity)
        .frame(height: reader.size.height/2.8)
        .foregroundStyle(viewModel.budget.status == .negative ? .cowpeas : .richBlack)
        .background(Color(viewModel.budget.status.rawValue))
        .padding(.vertical, Design.Padding.vertical * 4)
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
            cardLabel(title: title,
                      stat: stat,
                      reader: reader)
        }
    }
    
    @ViewBuilder
    private func cardLabel(
        title: String,
        stat: String,
        reader: GeometryProxy
    ) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title2)
                    .padding(.trailing, 2)
                
                Label("Detail", systemImage: "chevron.right.circle.fill")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .tint(Color.gray700)
            }
            
            Text(stat)
                .font(.largeTitle)
                .foregroundStyle(.accent)
                .padding(.top, reader.size.height/60)
                .padding(.bottom, reader.size.height/30)
        }
        .padding()
        .background(Color.cardLabel)
        .clipShape(.rect(cornerRadius: 25))
        .tint(Color.foreground)
    }
    
    @ToolbarContentBuilder
    private func dashboardToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button {
                showPreferences = true
            } label: {
                Label("Settings", systemImage: "book.and.wrench")
            }
        }
    }
    
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

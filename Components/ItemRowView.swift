//
//  ItemRowView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that shows metadata of an item in a cart.

import SwiftUI
import CoreData
internal import Combine

struct ItemRowView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    @ObservedObject var item: CDItem
    
    @Binding var showItemInfo: Bool
    
    let proxy: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? true
    }
    
    private var isWide: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if !isEditing {
                    Checkcircle(viewModel: viewModel,
                                item: item)
                    .padding(.top, Design.Padding.top)
                    .padding(.trailing, 3)
                }
                
                ItemOverviewLabel(
                    imageURL: item.imageURL,
                    name: item.displayName,
                    price: item.price,
                    details: item.displayNotes,
                    itemColor: item.itemColor,
                    proxy: proxy
                )
                .frame(height: 100, alignment: .leading)
                .padding(.horizontal, Design.Padding.horizontal)
                
                Spacer()
                
                if !isEditing {
                    InformationButton(
                        navModel: navModel,
                        item: item,
                        showItemInfo: $showItemInfo
                    )
                    .padding(.top, Design.Padding.top)
                    .padding(.leading, 3)
                }
            }
            
            if !isEditing {
                HStack(alignment: .bottom) {
                    Spacer()
                    QuantityStepper(
                        viewModel: viewModel,
                        item: item
                    )
                    .frame(width: Design.quantityStepperWidth)
                    .padding(.horizontal, Design.Padding.horizontal)
                }
                .padding(.vertical, Design.Padding.vertical)
            }
        }
        .frame(height: isEditing ? 100 : 132)
    }
}

#Preview {
    GeometryReader { proxy in
        NavigationStack {
            List {
                ItemRowView(viewModel: .preview,
                            navModel: NavigationModel(),
                            item: .preview,
                            showItemInfo: .constant(false),
                            proxy: proxy)
            }
            .navigationTitle("Checklist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

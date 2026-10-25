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
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var item: CDItem
    @Binding var showItemInfo: Bool
    let reader: GeometryProxy
    let deleteAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            rowLabel(isEditing: editMode?.wrappedValue.isEditing ?? true)
        }
        .opacity(editMode?.wrappedValue.isEditing ?? true ? 0.5 : 1)
        .swipeActions(edge: .trailing) {
            DeleteSwipeButton(action: deleteAction)
        }
        .swipeActions(edge: .trailing) {
            EditSwipeButton {
                navModel.selectedItem = item
                showItemInfo = true
            }
        }
    }
    
    @ViewBuilder
    private func rowLabel(isEditing: Bool) -> some View {
        HStack {
            if !isEditing {
                Checkcircle(viewModel: viewModel,
                            item: item)
            }
            
            columnLabel()
            Spacer()
            
            if !isEditing {
                InformationButton(navModel: navModel,
                                  item: item,
                                  showItemInfo: $showItemInfo)
            }
        }
    }
    
    private func columnLabel() -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    ItemOverviewLabel(
                        imageURL: item.imageURL,
                        name: item.displayName,
                        price: item.price,
                        itemColor: item.itemColor,
                        reader: reader
                    )
                    .padding(.horizontal, Design.Padding.horizontal)
                }
                .frame(width: reader.size.width/2,
                       height: reader.size.height/9)
                
                Spacer()
            }
            
            HStack(alignment: .bottom) {
                Spacer()
                
                VStack(alignment: .trailing) {
                    Spacer()
                    QuantityStepper(viewModel: viewModel,
                                    item: item)
                    .padding(.horizontal, Design.Padding.horizontal)
                }
                .frame(width: Design.quantityStepperWidth)
            }
        }
    }
}

#Preview() {
    GeometryReader { reader in
        List {
            ItemRowView(viewModel: .preview,
                        navModel: NavigationModel(),
                        item: .preview,
                        showItemInfo: .constant(false),
                        reader: reader,
                        deleteAction: { })
        }
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

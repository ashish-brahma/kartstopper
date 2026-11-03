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
    
    private var stepperWidth: CGFloat {
        horizontalSizeClass == .compact ? proxy.size.width/1.33 : Design.quantityStepperWidth
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            rowLabel()
                .frame(height: 120)
                .padding(.bottom, Design.Padding.bottom/2)
            
            stepperRow()
                .padding(.bottom, Design.Padding.bottom/2)
            
        }
        .opacity(isEditing ? 0.5 : 1)
    }
    
    @ViewBuilder
    private func rowLabel() -> some View {
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
            .padding(.horizontal, Design.Padding.horizontal)
            .frame(alignment: .leading)
            
            Spacer()
            
            if !isEditing {
                InformationButton(navModel: navModel,
                                  item: item,
                                  showItemInfo: $showItemInfo)
                .padding(.top, Design.Padding.top)
                .padding(.leading, 3)
            }
        }
    }
    
    private func stepperRow() -> some View {
        HStack(alignment: .bottom) {
            Spacer()
            
            VStack(alignment: .trailing) {
                Spacer()
                QuantityStepper(viewModel: viewModel,
                                item: item)
                .padding(.horizontal, Design.Padding.horizontal)
            }
            .frame(width: stepperWidth)
        }
    }
}

#Preview() {
    GeometryReader { proxy in
        List {
            ItemRowView(viewModel: .preview,
                        navModel: NavigationModel(),
                        item: .preview,
                        showItemInfo: .constant(false),
                        proxy: proxy)
        }
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

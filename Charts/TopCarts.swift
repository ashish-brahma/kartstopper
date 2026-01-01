//
//  TopCarts.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/12/25.
//
//  A chart view which visualizes the top 5 carts by item count.

import SwiftUI
import Charts
import CoreData

struct TopCarts: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var data: [CartCountData] {
        var data = [CartCountData]()
        for cart in carts {
            data.append(
                .init(name: cart.displayName,
                      itemCount: CDCart.getTotalItems(for: cart,          context: viewContext))
            )
        }
        data = data.sorted { $0.itemCount > $1.itemCount }
        return Array(data.prefix(5))
    }
    
    var maxCount: Int? {
        data.map { $0.itemCount }.max()
    }
    
    var topCartName: String {
        let name = data.first(where: { $0.itemCount == maxCount })?.name
        return name ?? ""
    }
    
    var body: some View {
        if !data.isEmpty {
            VStack(alignment: .leading) {
                Text("\(topCartName)").font(.callout.bold())
                + Text(" contains ").font(.callout)
                + Text("\(maxCount ?? 0)").font(.callout.bold())
                + Text(" items").font(.callout)
                
                Text("Top Cart")
                    .font(.callout.bold())
                    .foregroundStyle(.secondary)
                
                Chart(data) { element in
                    BarMark(
                        x: .value("Items", element.itemCount),
                        y: .value("Name", element.name)
                    )
                    .foregroundStyle(element.itemCount == maxCount ? .mint : .secondary)
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(stroke: StrokeStyle(lineWidth: 0))
                }
            }
        }
    }
}

struct CartCountData: Identifiable {
    let name: String
    let itemCount: Int
    var id: String { name }
}

#Preview {
    VStack {
        TopCarts()
            .frame(height: 300)
            .environment(\.managedObjectContext,
                          PersistenceController.preview.container.viewContext)
    }
    .padding()
}


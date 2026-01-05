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

struct CartsFrequencyChart: View {
    var data: [CartCountData]
    
    var body: some View {
        Chart(data) { element in
            BarMark(
                x: .value("Items", element.itemCount),
                y: .value("Name", element.name)
            )
            .foregroundStyle(element.itemCount ==  CartCountData.getMaxCount(data: data) ? .mint : .secondary)
            .annotation {
                if element.itemCount ==  CartCountData.getMaxCount(data: data) {
                    Text("\(element.itemCount)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .overlay {
            if data.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TopCarts: View {
    let reader: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var data: [CartCountData] {
        CartCountData.topCartsData(carts: carts,
                                   context: viewContext)
    }
    
    var topCartName: String {
        let name = data.first {
            $0.itemCount == CartCountData.getMaxCount(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Most Frequent Cart")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(data.isEmpty ? "-" : "\(topCartName)")
                    .font(.title2.bold())
                    .foregroundStyle(Color.foreground)
            }
            
            Spacer(minLength: reader.size.width/10)
            
            VStack {
                Spacer()
                CartsFrequencyChart(data: data)
                    .padding(.top, Design.Padding.top)
                    .frame(height: 60)
            }
        }
        .frame(height: 100)
    }
}

struct CartCountData: Identifiable {
    let name: String
    let itemCount: Int
    var id: String { name }
}

extension CartCountData {
    static func topCartsData(
        carts: FetchedResults<CDCart>,
        context: NSManagedObjectContext
    ) -> [CartCountData] {
        var data = [CartCountData]()
        for cart in carts {
            data.append(
                .init(name: cart.displayName,
                      itemCount: CDCart.getTotalItems(for: cart,          context: context))
            )
        }
        data = data.sorted { $0.itemCount > $1.itemCount }
        return Array(data.prefix(5))
    }
    
    static func getMaxCount(data: [CartCountData]) -> Int? {
        data.map { $0.itemCount }.max()
    }
}

#Preview {
    GeometryReader { reader in
        VStack {
            TopCarts(reader: reader)
                .frame(height: 300)
        }
        .padding()
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}


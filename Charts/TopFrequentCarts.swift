//
//  TopFrequentCarts.swift
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
    
    private var topCarts: [CartCountData] {
        data.filter {
            $0.itemCount == CartCountData.getMaxCount(data: data)
        }
    }
    
    private var topCount: Int? {
        CartCountData.getMaxCount(data: data)
    }
    
    var body: some View {
        Chart(data) { element in
            BarMark(
                x: .value("Items", element.itemCount),
                y: .value("Name", element.name)
            )
            .foregroundStyle(element.itemCount == topCount ? .mint : .secondary)
            .annotation(position: .top) {
                if element.itemCount == topCount {
                    Text("\(element.itemCount)")
                        .font(topCarts.count > 1 ? .caption : .callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(topCarts.count > 1 ? .visible : .hidden)
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                if let cartName = value.as(String.self) {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                        .font(isTopCart(cartName) ? .callout.bold() : .callout)
                        .foregroundStyle(isTopCart(cartName) ? .accent : .secondary)
                }
            }
        }
        .overlay {
            if data.isEmpty {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func isTopCart(_ cartName: String) -> Bool {
        topCarts.map(\.name).contains { $0 == cartName }
    }
}

struct TopFrequentCarts: View {
    let proxy: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    private var data: [CartCountData] {
        CartCountData.topCartsData(carts: Array(carts),
                                   context: viewContext)
    }
    
    private var topCartNames: [String] {
        let topCarts = data.filter {
            $0.itemCount == CartCountData.getMaxCount(data: data)
        }
        let names = topCarts.map(\.name)
        return names
    }
    
    private var subtitle: String {
        let topCount = topCartNames.count > 1 ? topCartNames.count : nil
        if let count = topCount {
            return "Top \(count) Carts"
        } else {
            return "Top Cart"
        }
    }
    
    var body: some View {
        if !data.isEmpty {
            VStack(alignment: .leading) {
                Text("\(subtitle)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                if topCartNames.count == 1 {
                    if let cartName = topCartNames.first {
                        Text("\(cartName)")
                            .font(.title2.bold())
                            .foregroundStyle(Color.foreground)
                    }
                }
                
                HStack {
                    Spacer(minLength: proxy.size.width/3)
                    CartsFrequencyChart(data: data)
                        .padding(.top, -1.5 * Design.Padding.top)
                        .frame(height: topCartNames.count > 1 ? 180 : 60)
                }
            }
        } else {
            DisclosureGroup {
                HStack {
                    Spacer()
                    ContentView.unavailableView(
                        label: "No Items",
                        symbolName: "checklist",
                        description: "Carts with the most number of items are analyzed here."
                    )
                    .frame(minWidth: proxy.size.width/1.2)
                    Spacer()
                }
            } label: {
                Text("Top Carts")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(Color.warning)
            }
        }
    }
}

#Preview {
    GeometryReader { proxy in
        List {
            TopFrequentCarts(proxy: proxy)
        }
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}


//
//  CategoryDetails.swift
//  KartStopper
//
//  Created by Ashish Brahma on 09/01/26.
//
//  A chart view which visualizes the top 5 most expensive carts.

import SwiftUI
import Charts
import CoreData

struct CategoryDetailsChart: View {
    var data: [CartExpenseData]
    
    @Environment(\.locale) private var locale
    
    var chartData: [CartExpenseData] {
        CartExpenseData.sort(data, by: .expense)
    }
    
    var topCartName: String {
        let name = data.first {
            $0.expense == CartExpenseData.getMaxExpense(data: data)
        }?.name
        return name ?? ""
    }
    
    var maxExpense: Double {
        CartExpenseData.getMaxExpense(data: data) ?? 0.0
    }
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                if #available(iOS 17.0, *) {
                    // Use chart background to display label.
                } else {
                    HStack {
                        chartLabel(reader: reader,
                                   horizontalAlignment: .leading)
                        Spacer()
                    }
                }
                
                Chart(chartData) { element in
                    if #available(iOS 17.0, *) {
                        SectorMark(
                            angle: .value("Expenses", element.expense),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5.0)
                        .foregroundStyle(by: .value("Name", element.name))
                        .opacity(element.name == topCartName ? 1 : 0.3)
                    } else {
                        BarMark(
                            x: .value("Expenses", element.expense),
                            y: .value("Name", element.name)
                        )
                        .foregroundStyle(element.name == topCartName ? .pink : .secondary)
                        .annotation(position: .overlay) {
                            Text("\(element.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                                .font(.callout)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .chartLegend(alignment: .center, spacing: 18)
                .chartBackground { chartProxy in
                    GeometryReader { reader in
                        if #available(iOS 17.0, *) {
                            if let anchor = chartProxy.plotFrame {
                                chartLabel(
                                    reader: reader,
                                    horizontalAlignment: .center
                                )
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: reader.size.width / 2.2)
                                    .position(x: reader[anchor].midX,
                                              y: reader[anchor].midY)
                            }
                        }
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
    }
    
    @ViewBuilder
    private func chartLabel(
        reader: GeometryProxy,
        horizontalAlignment: HorizontalAlignment
    ) -> some View {
        VStack(alignment: horizontalAlignment) {
            Text("Most Expensive Cart")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(data.isEmpty ? "-" : "\(topCartName)")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            Text("worth \(maxExpense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.bottom, Design.Padding.bottom)
        }
    }
}

struct CategoryDetails : View {
    @State private var timeRange: TimeRange = .last30days
    @State private var sortParameter: SortParameter = .expense
    @State private var showAllData: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var filterDateRange: ClosedRange<Date> {
        let dateRange = CDItem.dateRange(context: viewContext)
        let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * timeRange.rawValue)
        let end = dateRange.upperBound
        return start...end
    }
    
    var timeRangeStart: String {
        let date = filterDateRange.lowerBound
        return date.formatted(.dateTime.year().month().day())
    }
    
    var timeRangeEnd: String {
        let date = filterDateRange.upperBound
        return date.formatted(.dateTime.year().month().day())
    }
    
    var data: [CartExpenseData] {
        let data = CartExpenseData.periodicData(
            range: filterDateRange,
            carts: Array(carts),
            context: viewContext
        )
        
        return CartExpenseData.sort(data, by: sortParameter)
    }
    
    var top5data: [CartExpenseData] {
        Array(data.prefix(5))
    }
    
    var topCartName: String {
        let name = data.first {
            $0.expense == CartExpenseData.getMaxExpense(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        GeometryReader { reader in
            List {
                Section {
                    CategoryDetailsChart(data: data)
                        .frame(height: reader.size.height/2)
                } header: {
                    TimeRangePicker(value: $timeRange)
                } footer: {
                    Text("\(timeRangeStart) - \(timeRangeEnd)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    SortButton(value: $sortParameter)
                } header: {
                    Text("Cart Value")
                        .font(.title2.bold())
                        .foregroundStyle(Color.foreground)
                }
                
                Section {
                    expenses(data: showAllData ? data : top5data)
                    
                    if data.count > 5 {
                        ExpandButton(showAllData: $showAllData)
                    }
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.background)
        }
    }
    
    @ViewBuilder
    private func expenses(data: [CartExpenseData]) -> some View {
        ForEach(data) { cart in
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("\(cart.date.formatted(Date.customStyle))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(cart.name)")
                        .font(.title3)
                        .foregroundStyle(.primary)
                    
                    Group {
                        Text("\(percentage(expense: cart.expense), format: .percent.precision(.significantDigits(3)))")
                        + Text(" (^[\(cart.itemCount) Item](inflect: true))")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(Color.foreground)
                }
                
                Spacer()
                
                Text("\(cart.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func percentage(expense: Double) -> Double {
        return CartExpenseData.getPercentage(of: data,
                                             for: expense)
    }
}

#Preview {
    CategoryDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


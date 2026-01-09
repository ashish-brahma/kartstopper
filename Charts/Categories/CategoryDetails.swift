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
        Chart(data) { element in
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
            }
        }
        .chartLegend(alignment: .center, spacing: 18)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .scaledToFit()
        .chartBackground { chartProxy in
            GeometryReader { reader in
                if #available(iOS 17.0, *) {
                    if let anchor = chartProxy.plotFrame {
                        VStack {
                            Text(data.isEmpty ? "-" : "\(topCartName)")
                                .font(.title2.bold())
                                .foregroundStyle(Color.foreground)
                            
                            Text("Most Expensive Cart worth \(maxExpense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: reader.size.width / 2.2)

                        }
                        .position(x: reader[anchor].midX,
                                  y: reader[anchor].midY)
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

struct CategoryDetails : View {
    @State private var timeRange: TimeRange = .last30days
    @State private var sortParameter: SortParameter = .expense
    @State private var showAllData: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)])
    private var carts: FetchedResults<CDCart>
    
    var filterDateRange: ClosedRange<Date> {
        ExpenditureData.lastNDaysRange(
            days: timeRange.rawValue,
            context: viewContext
        )
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
        CartExpenseData.topCartsData(range: filterDateRange,
                                     carts: Array(carts),
                                     sortBy: sortParameter,
                                     context: viewContext)
    }
    
    var top5data: [CartExpenseData] {
        Array(data.prefix(5))
    }
    
    var chartData: [CartExpenseData] {
        CartExpenseData.topCartsData(range: filterDateRange,
                                     carts: Array(carts),
                                     sortBy: .expense,
                                     context: viewContext)
    }
    
    var topCartName: String {
        let name = data.first {
            $0.expense == CartExpenseData.getMaxExpense(data: data)
        }?.name
        return name ?? ""
    }
    
    var body: some View {
        List {
            Section {
                CategoryDetailsChart(data: chartData)
            } header: {
                TimeRangePicker(value: $timeRange)
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
                        .padding(.bottom, -Design.Padding.bottom)
                }
                
                Spacer()
                
                Text("\(cart.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, Design.Padding.bottom)
            }
        }
    }
}

#Preview {
    CategoryDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


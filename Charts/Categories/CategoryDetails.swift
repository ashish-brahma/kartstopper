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
    var mostExpensive: CartExpenseData
    
    let cumulativeExpenseRangesForCarts: [(name: String, range: Range<Double>)]
    
    @Environment(\.locale) private var locale
    
    @State var selectedExpense: Double? = nil
    
    init(
        data: [CartExpenseData]
    ){
        self.data = CartExpenseData.sort(data, by: .expense)
        
        let unknownCart = CartExpenseData(name: "Unknown",
                                          date: .now,
                                          expense: 0,
                                          itemCount: 0)
        
        self.mostExpensive = self.data.first ?? unknownCart
        
        var cumulative = 0.0
        self.cumulativeExpenseRangesForCarts = data.map {
            let newCumulative = cumulative + Double($0.expense)
            let result = (name: $0.name, range: cumulative..<newCumulative)
            cumulative = newCumulative
            return result
        }
    }
    
    var selectedCart: CartExpenseData? {
        if let selectedExpense,
           let selectedIndex = cumulativeExpenseRangesForCarts
            .firstIndex(where: {
               $0.range.contains(selectedExpense)  }) {
            return data[selectedIndex]
        }
        
        return nil
    }
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                header(reader: reader)
                
                if #available(iOS 17.0, *) {
                    chartView()
                        .chartLegend(alignment: .center, spacing: 18)
                        .chartAngleSelection(value: $selectedExpense)
                        .chartBackground { chartProxy in
                            backgroundView(chartProxy: chartProxy)
                        }
                } else {
                    chartView()
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
    private func header(reader: GeometryProxy) -> some View {
        if #available(iOS 17.0, *) {
            // Use chart background to display label.
        } else {
            HStack {
                chartLabel(reader: reader,
                           horizontalAlignment: .leading)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func chartView() -> some View {
        Chart(data) { element in
            if #available(iOS 17.0, *) {
                donutChart(element: element)
            } else {
                barChart(element: element)
            }
        }
    }
    
    @available(iOS 17.0, *)
    @ChartContentBuilder
    private func donutChart(element: CartExpenseData) -> some ChartContent {
        SectorMark(
            angle: .value("Expenses", element.expense),
            innerRadius: .ratio(0.618),
            angularInset: 1.5
        )
        .cornerRadius(5.0)
        .foregroundStyle(by: .value("Name", element.name))
        .opacity(element.name == (selectedCart?.name ?? mostExpensive.name) ? 1 : 0.3)
    }
    
    @ChartContentBuilder
    private func barChart(element: CartExpenseData) -> some ChartContent {
        BarMark(
            x: .value("Expenses", element.expense),
            y: .value("Name", element.name)
        )
        .foregroundStyle(element.name == mostExpensive.name ? .pink : .secondary)
        .annotation(position: .overlay) {
            Text("\(element.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                .font(.callout)
                .foregroundStyle(.white)
        }
    }
    
    @available(iOS 17.0, *)
    @ViewBuilder
    private func backgroundView(chartProxy: ChartProxy) -> some View {
        GeometryReader { reader in
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
    
    @ViewBuilder
    private func chartLabel(
        reader: GeometryProxy,
        horizontalAlignment: HorizontalAlignment
    ) -> some View {
        VStack(alignment: horizontalAlignment) {
            Text("Most Expensive Cart")
                .font(.callout)
                .foregroundStyle(.secondary)
                .opacity(selectedCart == nil || selectedCart?.name == mostExpensive.name ? 1 : 0)
            
            Text(data.isEmpty ? "-" : "\(selectedCart?.name ?? mostExpensive.name)")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
            
            Text("worth \(selectedCart?.expense ?? mostExpensive.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.bottom, Design.Padding.bottom)
        }
    }
}

// MARK: - Details view

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
                
                expenses(data: showAllData ? data : top5data)
                    
                if data.count > 5 {
                    ExpandButton(showAllData: $showAllData)
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
            Section {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(cart.date.formatted(date: .omitted,
                                                 time: .shortened))
                        .font(.subheadline)
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
            } header: {
                Text(cart.date.formatted(date: .abbreviated,
                                         time: .omitted))
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


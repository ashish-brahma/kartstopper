//
//  ExpenditureDetails.swift
//  KartStopper
//
//  Created by Ashish Brahma on 04/01/26.
//
//  A chart which depicts expediture details.

import SwiftUI
import Charts
import CoreData

struct DailyExpenditureChart: View {
    var data: [ExpenditureData]
    var timeRange: TimeRange
    @Binding var scrollPosition: Date
    var averageExpenditure: Double
    
    @Environment(\.locale) private var locale
    
    var axisMarkCount: Int {
        var count = 0
        if timeRange == .last30days {
            count = 7
        } else if timeRange == .last7days {
            count = 1
        }
        return count
    }
    
    var axisValueLabelFormat: Date.FormatStyle {
        var format = Date.FormatStyle.dateTime
        if timeRange == .last30days {
            format = .dateTime.month().day()
        } else if timeRange == .last7days {
            format = .dateTime.weekday()
        }
        return format
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            chartView()
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 3600 * 24 * timeRange.rawValue)
                .chartScrollTargetBehavior(
                    .valueAligned(
                        matching: .init(hour: 0),
                        majorAlignment: .matching(.init(day: 1))
                    ))
                .chartScrollPosition(x: $scrollPosition)
        } else {
            chartView()
        }
    }
    
    @ViewBuilder
    private func chartView() -> some View {
        Chart {
            ForEach(data) {
                BarMark(x: .value("Day", $0.date, unit: .day),
                        y: .value("Expenses", $0.expense))
            }
            .foregroundStyle(.sanskrit)
            
            RuleMark(y: .value("Average", averageExpenditure))
                .foregroundStyle(.accent)
                .lineStyle(StrokeStyle(lineWidth: 3, dash: [5,3]))
                .annotation(position: .automatic) {
                    Text("avg")
                        .foregroundStyle(.accent)
                }
        }
        .chartXAxis {
            if timeRange != .last365days {
                AxisMarks(values: .stride(by: .day, count: axisMarkCount)) {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(format: axisValueLabelFormat)
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

// MARK: - Monthly Chart

struct MonthlyExpenditureChart: View {
    var data: [ExpenditureData]
    var averageExpenditure: Double
    
    @Environment(\.locale) private var locale
    
    var body: some View {
        Chart {
            ForEach(data) {
                BarMark(x: .value("Day", $0.date, unit: .month),
                        y: .value("Expenses", $0.expense))
            }
            
            RuleMark(y: .value("Average", averageExpenditure))
                .foregroundStyle(.accent)
                .lineStyle(StrokeStyle(lineWidth: 3, dash: [5,3]))
                .annotation(position: .trailing) {
                    Text("avg")
                        .foregroundStyle(.accent)
                }
        }
        .foregroundStyle(.sanskrit)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow))
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

// MARK: - Details view

struct ExpenditureDetails: View {
    @State private var selectedTimeRange: TimeRange = .last7days
    @State private var sortParameter: SortParameter = .expense
    @State private var showAllData: Bool = false
    @State private var scrollPositionStart: Date = .distantPast
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var filterDateRange: ClosedRange<Date> {
        let dateRange = CDItem.dateRange(context: viewContext)
        var days: TimeInterval = 0
        if #available(iOS 17.0, *) {
            days = selectedTimeRange == .last7days ? TimeRange.last30days.rawValue : TimeRange.last365days.rawValue
        } else {
            days = selectedTimeRange.rawValue
        }
        let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * days)
        let end = dateRange.upperBound
        return start...end
    }
    
    var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * selectedTimeRange.rawValue)
    }
    
    var scrollTimeRangeStart: String {
        scrollPositionStart.formatted(.dateTime.year().month().day())
    }
    
    var scrollTimeRangeEnd: String {
        scrollPositionEnd.formatted(.dateTime.year().month().day())
    }
    
    var filterDateStart: String {
        filterDateRange.lowerBound.formatted(.dateTime.year().month().day())
    }
    
    var filterDateEnd: String {
        filterDateRange.upperBound.formatted(.dateTime.year().month().day())
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: filterDateRange,
                                     sortBy: sortParameter,
                                     context: viewContext)
    }
    
    var scrollData: [ExpenditureData] {
        ExpenditureData.periodicData(
            range: scrollPositionStart...scrollPositionEnd,
            sortBy: sortParameter,
            context: viewContext
        )
    }
    
    var interactiveData: [ExpenditureData] {
        var data = [ExpenditureData]()
        if #available(iOS 17.0, *) {
            data = scrollData
        } else {
            data = self.data
        }
        return data
    }
    
    var top5Data: [ExpenditureData] {
        Array(interactiveData.prefix(5))
    }
    
    var totalExpenditure: Double {
        interactiveData.map { $0.expense }.reduce(0, +)
    }
    
    var averageExpenditure: Double {
        return totalExpenditure / Double(interactiveData.count)
    }
    
    var body: some View {
        List {
            Section {
                chartContent()
            } header: {
                TimeRangePicker(value: $selectedTimeRange)
            }
            
            Section {
                SortButton(value: $sortParameter)
            } header: {
                Text("Expenses")
                    .font(.title2.bold())
                    .foregroundStyle(Color.foreground)
            }
            
            Section {
                expenses(data: showAllData ? interactiveData : top5Data)
                
                if interactiveData.count > 5 {
                    ExpandButton(showAllData: $showAllData)
                }
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .task {
            updateScrollPosition()
        }
        .onChange(of: selectedTimeRange) { _ in
            updateScrollPosition()
        }
    }
    
    private func updateScrollPosition() {
        scrollPositionStart = CDItem.dateRange(context: viewContext).upperBound.addingTimeInterval(-1 * 3600 * 24 * selectedTimeRange.rawValue)
    }
    
    @ViewBuilder
    private func chartContent() -> some View {
        VStack(alignment: .leading) {
            Text("Total Expenditure")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text(totalExpenditure, format: .currency(code: locale.currency?.identifier ?? "USD"))
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
                .padding(.bottom, Design.Padding.bottom)
            
            Text("Average Expenditure")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text("\(averageExpenditure, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
                .padding(.bottom, Design.Padding.bottom)
            
            if #available(iOS 17.0, *) {
                Text("\(scrollTimeRangeStart) - \(scrollTimeRangeEnd)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(filterDateStart) - \(filterDateEnd)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            switch selectedTimeRange {
            case .last7days, .last30days:
                DailyExpenditureChart(
                    data: data,
                    timeRange: selectedTimeRange,
                    scrollPosition: $scrollPositionStart,
                    averageExpenditure: averageExpenditure
                )
                    .frame(height: 240)
            case .last365days:
                MonthlyExpenditureChart(
                    data: data,
                    averageExpenditure: averageExpenditure
                )
                    .frame(height: 240)
            }
        }
    }
    
    @ViewBuilder
    private func expenses(data: [ExpenditureData]) -> some View {
        ForEach(data) { item in
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("\(item.date.formatted(Date.customStyle))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(item.name)")
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .padding(.bottom, -Design.Padding.bottom)
                    
                    Text("\(item.cartName)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.foreground)
                }
                
                Spacer()
                
                Text("\(item.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, Design.Padding.bottom)
            }
        }
    }
}

#Preview {
    ExpenditureDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


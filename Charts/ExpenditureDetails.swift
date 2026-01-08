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
    
    @Environment(\.locale) private var locale
    
    var averageExpenditure: Double {
        let total = data.map { $0.expense }.reduce(0, +)
        return total / Double(data.count)
    }
    
    var body: some View {
        Chart {
            ForEach(data) {
                BarMark(x: .value("Day", $0.date, unit: .day),
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
            AxisMarks(values: .stride(by: .day, count: 7)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
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

struct MonthlyExpenditureChart: View {
    var data: [ExpenditureData]
    
    @Environment(\.locale) private var locale
    
    var averageExpenditure: Double {
        let total = data.map { $0.expense }.reduce(0, +)
        return total / Double(data.count)
    }
    
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

struct ExpenditureDetails: View {
    @State private var timeRange: TimeRange = .last30days
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var filterDateRange: ClosedRange<Date> {
        ExpenditureData.lastNDaysRange(
            days: timeRange.rawValue,
            context: viewContext
        )
    }
    
    var timeRangeStart: String {
        dateLabel(for: filterDateRange.lowerBound)
    }
    
    var timeRangeEnd: String {
        filterDateRange.upperBound.formatted(.dateTime.year().month().day())
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: filterDateRange,
                                     context: viewContext)
    }
    
    var top5Data: [TopExpenseData] {
        ExpenditureData.top5Data(range: filterDateRange,
                                 context: viewContext)
    }
    
    var totalExpenditure: Double {
        data.map { $0.expense }.reduce(0, +)
    }
    
    var averageExpenditure: Double {
        return totalExpenditure / Double(data.count)
    }
    
    var body: some View {
        List {
            Section {
                chartContent()
            }
            
            Section("Top Expenses") {
                topExpenses()
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
    
    @ViewBuilder
    private func chartContent() -> some View {
        VStack(alignment: .leading) {
            TimeRangePicker(value: $timeRange)
                .padding(.bottom, Design.Padding.bottom)
            
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
            
            Text("\(timeRangeStart) - \(timeRangeEnd)")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            switch timeRange {
            case .last30days:
                DailyExpenditureChart(data: data)
                    .frame(height: 240)
            case .last365days:
                MonthlyExpenditureChart(data: data)
                    .frame(height: 240)
            }
        }
    }
    
    @ViewBuilder
    private func topExpenses() -> some View {
        ForEach(top5Data, id: \.name) { item in
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
    
    private func dateLabel(for date: Date) -> String {
        switch timeRange {
        case .last30days:
            date.formatted(.dateTime.month().day())
        case .last365days:
            date.formatted(.dateTime.year().month().day())
        }
    }
}

#Preview {
    ExpenditureDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


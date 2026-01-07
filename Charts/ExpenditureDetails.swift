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

struct ExpenditureDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var timeRange: ClosedRange<Date> {
        CDItem.dateRange(context: viewContext)
    }
    
    var timeRangeStart: String {
        timeRange.lowerBound.formatted(.dateTime.month().day())
    }
    
    var timeRangeEnd: String {
        timeRange.upperBound.formatted(.dateTime.year().month().day())
    }
    
    var data: [ExpenditureData] {
        ExpenditureData.periodicData(range: timeRange,
                                     context: viewContext)
    }
    
    var top5Data: [(name: String, expense: Double)] {
        ExpenditureData.top5Data(range: timeRange,
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
                
                Text("\(timeRangeStart) - \(timeRangeEnd)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                DailyExpenditureChart(data: data)
                    .frame(height: 240)
            }
            
            Section("Top Expenses") {
                ForEach(top5Data, id: \.name) { item in
                    HStack {
                        Text("\(item.name)")
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("\(item.expense, format: .currency(code: locale.currency?.identifier ?? "USD"))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
}

#Preview {
    ExpenditureDetails()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}


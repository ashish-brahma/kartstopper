//
//  StatusCardView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/12/25.
//
//  A SwiftUI view that shows a gauge measuring the
//  total amount spent out of the monthly budget.

import SwiftUI

struct StatusCardView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.locale) private var locale
    
    @State private var current = 0.0
    @State private var minValue = 0.0
    @State private var maxValue = 0.0
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        VStack {
            Gauge(value: current > maxValue ? maxValue: current, in: minValue...maxValue) {
                Text("This month you have spent")
                    .font(
                        Font.system(.headline,
                                    design: .serif,
                                    weight: .medium)
                        .italic()
                    )
                    .padding(.bottom, Design.Padding.bottom * 4)
                
            } currentValueLabel: {
                
                Text(current, format: .currency(code: currencyCode))
                    .font(
                        Font.system(.largeTitle,
                                    design: .serif,
                                    weight: .light)
                    )
                    .foregroundStyle(viewModel.fontColor)
                
            } minimumValueLabel: {
                
                Text(minValue, format: .currency(code: currencyCode))
                    .font(.callout)
                
            } maximumValueLabel: {
                
                Text(maxValue, format: .currency(code: currencyCode))
                    .font(.callout)
            }
            .tint(viewModel.gaugeColor)
        }
        .padding()
        .clipShape(.rect(cornerRadius: 25))
        .foregroundStyle(viewModel.budget.status == .negative ? .cowpeas : .richBlack)
        .task {
            current = viewModel.budget.totalMonthlySpend
            maxValue = viewModel.budget.budgetAmount ?? 0.0
        }
    }
}

#Preview {
    StatusCardView(viewModel: .preview)
        .background(Color.background)
}

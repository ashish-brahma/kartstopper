//
//  StatusCardView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/12/25.
//

import SwiftUI

struct StatusCardView: View {
    let reader: GeometryProxy
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.locale) private var locale
    
    @State private var current = 0.0
    @State private var minValue = 0.0
    @State private var maxValue = 0.0
    
    var body: some View {
        VStack {
            Gauge(value: current > maxValue ? maxValue: current, in: minValue...maxValue) {
                Text("This month you have spent")
                    .font(Font.custom(Design.Fonts.italicCaption,
                                      size: Design.Fonts.itaticCaptionFontSize))
                    .padding(.bottom, Design.Padding.bottom * 4)
            } currentValueLabel: {
                currencyLabel(for: current)
                    .font(Font.custom(Design.Fonts.largeNumber,
                                      size: Design.Fonts.largeNumberFontSize))
                    .foregroundStyle(viewModel.fontColor)
            } minimumValueLabel: {
                currencyLabel(for: minValue)
            } maximumValueLabel: {
                currencyLabel(for: maxValue)
            }
            .tint(viewModel.gaugeColor)
            .padding()
        }
        .frame(height: reader.size.height/3.2)
        .padding()
        .clipShape(.rect(cornerRadius: 25))
        .foregroundStyle(viewModel.budget.status == .negative ? .cowpeas : .richBlack)
        .padding(.vertical, Design.Padding.vertical * 4)
        .task {
            current = viewModel.budget.totalMonthlySpend
            maxValue = viewModel.budget.budgetAmount
        }
    }
    
    func currencyLabel(for amount: Double) -> some View {
        Text(amount, format: .currency(code: locale.currency?.identifier ?? "USD"))
    }
}

#Preview {
    GeometryReader { reader in
        StatusCardView(reader: reader,
                       viewModel: .preview)
    }
}

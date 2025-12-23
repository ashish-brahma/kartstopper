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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                message()
                Spacer()
            }
            .padding(.top, reader.size.height/30)
            .padding(Design.Padding.standard * 2)
            .position(x: reader.size.width/2,
                      y: reader.size.height/24)
            
            monthlySpend()
        }
        .frame(maxWidth: .infinity)
        .frame(height: reader.size.height/2.8)
        .foregroundStyle(viewModel.budget.status == .negative ? .cowpeas : .richBlack)
        .background(Color(viewModel.budget.status.rawValue))
        .padding(.vertical, Design.Padding.vertical * 4)
    }
    
    @ViewBuilder
    private func message() -> some View {
        Text("This month you have spent")
            .font(Font.custom(Design.Fonts.italicCaption, size: 16))
    }
    
    @ViewBuilder
    private func monthlySpend() -> some View {
        VStack {
            Text(viewModel.budget.totalMonthlySpend.formatted(.currency(code: locale.currency?.identifier ?? "USD")))
                .font(Font.custom(Design.Fonts.largeNumber, size: 80))
                .minimumScaleFactor(0.7)
                .padding(.top, reader.size.height/20)
        }
        .padding(.bottom, reader.size.height/10)
        .position(x: reader.size.width/2,
                  y: reader.size.height/20)
    }
}

#Preview {
    GeometryReader { reader in
        StatusCardView(reader: reader,
                       viewModel: .preview)
    }
}

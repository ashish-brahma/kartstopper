//
//  CardLabelView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/12/25.
//

import SwiftUI

struct CardLabelView<Content: View>: View {
    let title: String
    var stat: String = ""
    var description: String = ""
    var iconColor: Color = .gray700
    var fontColor: Color = Color.foreground
    var statColor: Color = .accent
    let reader: GeometryProxy
    var content: Content
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title.bold())
                        .foregroundStyle(fontColor)
                    
                    
                    if !stat.isEmpty {
                        Text(stat)
                            .font(.title2)
                            .foregroundStyle(statColor)
                    }
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(.callout.bold())
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.bottom, Design.Padding.bottom)
            
            content
        }
    }
}

#Preview {
    GeometryReader { reader in
        CardLabelView(title: "Stat",
                      stat: "0",
                      description: "Insights about the stat",
                      fontColor: .primary,
                      reader: reader,
                      content: TopCarts())
        .frame(height: reader.size.height/4)
        .padding(.top, Design.Padding.top * 4)
    }
}

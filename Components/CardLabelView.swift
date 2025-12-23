//
//  CardLabelView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/12/25.
//

import SwiftUI

struct CardLabelView: View {
    let title: String
    var stat: String = ""
    var description: String = ""
    var detailIcon: String = "arrowtriangle.up.square.fill"
    var iconColor: Color = .gray700
    var fontColor: Color = Color.foreground
    var statColor: Color = .accent
    var backgroundColor: Color = .cardLabel
    let reader: GeometryProxy
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(fontColor)
                
                Spacer()
                
                Label("Detail", systemImage: detailIcon)
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .foregroundStyle(iconColor)
            }
            
            VStack {
                if !stat.isEmpty {
                    Text(stat)
                        .font(.largeTitle)
                        .foregroundStyle(statColor)
                }
                
                if !description.isEmpty {
                    Text(description)
                        .font(.footnote.italic())
                        .foregroundStyle(fontColor)
                    
                    Spacer(minLength: reader.size.height/20)
                }
            }
            .padding(.top, reader.size.height/60)
            .padding(.bottom, reader.size.height/25)
        }
        .padding()
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 25))
        .tint(Color.foreground)
    }
}

#Preview {
    GeometryReader { reader in
        CardLabelView(title: "Stat",
                      stat: "0",
                      description: "Insights about the stat",
                      detailIcon: "arrowtriangle.up.square.fill",
                      fontColor: .primary,
                      backgroundColor: .neon,
                      reader: reader)
        .frame(height: reader.size.height/4)
        .padding(.top, Design.Padding.top * 4)
    }
}

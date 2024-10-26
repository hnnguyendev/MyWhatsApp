//
//  ChannelItemView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI

struct ChannelItemView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 3) {
                titleTextView()
                lastMessagePreview()
            }
        }
    }
    
    private func titleTextView() -> some View {
        HStack {
            Text("Motki Bubu")
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text("6:46 PM")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text("Last message")
            .lineLimit(2)
            .font(.system(size: 16))
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView()
}

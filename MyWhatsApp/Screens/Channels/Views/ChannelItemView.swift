//
//  ChannelItemView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: ChannelItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(channel, size: .medium)
            
            VStack(alignment: .leading, spacing: 3) {
                titleTextView()
                lastMessagePreview()
            }
        }
    }
    
    private func titleTextView() -> some View {
        HStack {
            Text(channel.title)
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text(channel.lastMessageTimestamp.dayOrTimeRepresentation)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        HStack(spacing: 4) {
            Image(systemName: channel.lastMessageType.iconName)
                .imageScale(.small)
                .foregroundStyle(.gray)
            
            Text(channel.previewMessage)
                .lineLimit(2)
                .font(.system(size: 16))
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}

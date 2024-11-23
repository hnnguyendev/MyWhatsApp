//
//  BubbleView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 23/11/24.
//

import SwiftUI

struct BubbleView: View {
    let message: MessageItem
    let channel: ChannelItem
    let isNewDay: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimestampTextView()
                    .padding()
            }
            composeDynamicBubbleView()
        }
    }
    
    @ViewBuilder
    private func composeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(item: message)
        case .photo, .video:
            BubbleImageView(item: message)
        case .audio:
            BubbleAudioView(item: message)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                newDayTimestampTextView()
                ChannelCreationTextView()
                    .padding()
                
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                }
            default:
                Text("UNKNOWN")
            }
        }
    }
    
    private func newDayTimestampTextView() -> some View {
        Text(message.timestamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(Color.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    BubbleView(message: .sentPlaceholder, channel: .placeholder, isNewDay: false)
}

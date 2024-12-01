//
//  BubbleTextView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import SwiftUI

struct BubbleTextView: View {
    let item: MessageItem
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
            }
            
            if item.direction == .sent {
                timestampTextView()
            }
            
            Text(item.text)
                .padding(10)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .applyTail(item.direction)
            
            if item.direction == .received {
                timestampTextView()
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
        .overlay(alignment: item.reactionAnchor) {
            MessageReactionView(message: item)
                .offset(x: item.showGroupPartnerInfo ? 50 : 0, y: 10)
        }
    }
    
    private func timestampTextView() -> some View {
        Text(item.timestamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
//        HStack {
//            Text(item.timestamp.formatToTime)
//                .font(.system(size: 13))
//                .foregroundStyle(.gray)
//            
//            if item.direction == .sent {
//                Image(.seen)
//                    .resizable()
//                    .renderingMode(.template)
//                    .frame(width: 15, height: 15)
//                    .foregroundStyle(Color(.systemBlue))
//            }
//        }
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceholder)
        BubbleTextView(item: .recievedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.4))
}
    

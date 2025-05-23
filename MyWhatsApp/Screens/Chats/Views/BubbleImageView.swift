//
//  BubbleImageView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 28/10/24.
//

import SwiftUI
import Kingfisher

struct BubbleImageView: View {
    let item: MessageItem
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.direction == .sent {
                Spacer()
            }
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
                    .offset(y: 5)
            }
            
            messageImageView()
                .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
                .overlay(alignment: item.reactionAnchor) {
                    MessageReactionView(message: item)
                        .padding(12)
                        .padding(.bottom, -20)
                }
            
//            HStack {
//                if item.direction == .sent {
//                    shareButton()
//                }
//                
//                messageTextView()
//                    .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
//                    .overlay {
//                        playButton()
//                            .opacity(item.type == .video ? 1 : 0)
//                    }
//                
//                if item.direction == .received {
//                    shareButton()
//                }
//            }
            
            if item.direction == .received {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }
    
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }
    
    private func messageImageView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
//            Image(.stubImage0)
            KFImage(URL(string: item.thumbnailUrl ?? ""))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGray5))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5))
                )
                .padding(5)
                .overlay(alignment: .bottomTrailing) {
                    timestampTextView()
                }
                .overlay {
                    playButton()
                        .opacity(item.type == .video ? 1 : 0)
                }
            
            if !item.text.isEmptyOrWhiteSpace {
                Text(item.text)
                    .padding([.horizontal, .bottom], 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: item.imageSize.width)
            }
        }
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .applyTail(item.direction)
    }
    
    private func timestampTextView() -> some View {
        HStack {
            Text(item.timestamp.formatToTime)
                .font(.system(size: 13))
            
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(Color(.systemGray3))
        .clipShape(Capsule())
        .padding(12)
    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.gray)
            .background(.thinMaterial)
            .clipShape(Circle())
    }
}

#Preview {
    ScrollView {
        BubbleImageView(item: .sentPlaceholder)
        BubbleImageView(item: .recievedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
}

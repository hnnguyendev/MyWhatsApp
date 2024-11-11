//
//  BubbleAudioView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 28/10/24.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
                    .offset(y: 5)
            }
            
            if (item.direction == .sent) {
                timestampTextView()
            }
            
            HStack {
                playButton()
                
                Slider(value: $sliderValue, in: sliderRange)
                    .tint(.gray)
                
                Text("02:22")
                    .foregroundStyle(.gray)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            
            if (item.direction == .received) {
                timestampTextView()
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }
    
    private func playButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "play.fill")
                .padding(10)
                .background(item.direction == .sent ? .white : .green)
                .clipShape(Circle())
                .foregroundStyle(item.direction == .sent ? .black : .white)
        }
    }
    
    private func timestampTextView() -> some View {
        Text("10:19 PM")
            .font(.footnote)
            .foregroundStyle(.gray)
//        HStack {
//            Text("10:19 PM")
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
        BubbleAudioView(item: .recievedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
    .onAppear() {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}

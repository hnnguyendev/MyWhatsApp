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
        VStack(alignment: item.horizontalAliment, spacing: 3) {
            Text("Hello, World! How are you doing")
                .padding(10)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .applyTail(item.direction)
            
            timestampTextView()
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 100)
        .padding(.trailing, item.direction == .sent ? 5 : 100)
    }
    
    private func timestampTextView() -> some View {
        HStack {
            Text("10:29 PM")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceholder)
        BubbleTextView(item: .recievedPlaceholder)
    }
    .background(Color.gray.opacity(0.1))
}
    

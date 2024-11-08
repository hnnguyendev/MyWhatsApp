//
//  ChatRoomScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    let channel: ChannelItem
//    @StateObject private var viewModel = ChatRoomViewModel()
    // ~ We can init like below
    @StateObject private var viewModel: ChatRoomViewModel
    init(channel: ChannelItem) {
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(channel))
    }
    
    var body: some View {
//        ScrollView {
//            LazyVStack {
//                ForEach(0..<12) { _ in
//                    Text("PLACEHOLDER")
//                        .font(.largeTitle)
//                        .bold()
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 200)
//                        .background(Color.gray.opacity(0.1))
//                }
//            }
//        }
        MessageListView()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .navigationBarTitleDisplayMode(.inline) /// Hidden redundant white space on top ChatRoomScreen
            .safeAreaInset(edge: .bottom) {
                TextInputArea(textMessage: $viewModel.textMessage) {
                    viewModel.sendMessage()
                }
            }
    }
}

extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Circle()
                    .frame(width: 35, height: 35)
                
                Text(channel.title)
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "video")
            }
            
            Button {
                
            } label: {
                Image(systemName: "phone")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen(channel: .placeholder)
    }
}

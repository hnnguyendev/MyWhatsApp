//
//  ChatRoomScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import SwiftUI

// 1. ChatRoomScreen which is top components to SwiftUI view
// 2. MessageListView which is also a SwiftUI view but it's a UI view representable, view representable which is just a SwiftUI way of converting a UIKit view into a SwiftUI view
// 3. That UIKit view that we're converting is this MessageListController which is a UIKit UITableView
// 4. We're just taking that viewModel all the way from the ChatRoomScreen, we're injecting the data into MessageListView and then we're injecting it into our UIKit view which is this MessageListController
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
        MessageListView(viewModel)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .navigationBarTitleDisplayMode(.inline) /// Hidden redundant white space on top ChatRoomScreen
            .safeAreaInset(edge: .bottom) {
//                TextInputArea(textMessage: $viewModel.textMessage) {
//                    viewModel.sendMessage()
//                }
                bottomSafeAreaView()
            }
    }
    
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 0) {
            Divider()
            
            MediaAttachmentPreview()
            
            Divider()
            
            TextInputArea(textMessage: $viewModel.textMessage) {
                viewModel.sendMessage()
            }
        }
    }
}

extension ChatRoomScreen {
    private var channelTitle: String {
        let maxChar = 20
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        return title
    }
    
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                CircularProfileImageView(channel, size: .mini)
                
                Text(channelTitle)
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

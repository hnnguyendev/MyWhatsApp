//
//  ChatRoomScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import SwiftUI
import PhotosUI

// 1. ChatRoomScreen which is top components to SwiftUI view
// 2. MessageListView which is also a SwiftUI view but it's a UI view representable, view representable which is just a SwiftUI way of converting a UIKit view into a SwiftUI view
// 3. That UIKit view that we're converting is this MessageListController which is a UIKit UITableView
// 4. We're just taking that viewModel all the way from the ChatRoomScreen, we're injecting the data into MessageListView and then we're injecting it into our UIKit view which is this MessageListController
struct ChatRoomScreen: View {
    let channel: ChannelItem
//    @StateObject private var viewModel = ChatRoomViewModel()
    // ~ We can init like below
    @StateObject private var viewModel: ChatRoomViewModel
    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    
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
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.photoPickerItems,
                maxSelectionCount: 6,
                photoLibrary: .shared()
            )
            .navigationBarTitleDisplayMode(.inline) /// Hidden redundant white space on top ChatRoomScreen
            .ignoresSafeArea(edges: .bottom)
            .safeAreaInset(edge: .bottom) {
//                TextInputArea(textMessage: $viewModel.textMessage) {
//                    viewModel.sendMessage()
//                }
                bottomSafeAreaView()
                    .background(Color.whatsAppWhite)
            }
            .animation(.easeInOut, value: viewModel.showPhotoPickerPreview)
            .fullScreenCover(isPresented: $viewModel.videoPlayerState.show) {
                if let player = viewModel.videoPlayerState.player {
                    MediaPlayerView(player: player) {
                        viewModel.dismissVideoPlayer()
                    }
                }
            }
            /// Inject voiceMessagePlayer into all of ChatRoomScreen
            /// All of the children view of for example MessageListView is going to be able to access voiceMessagePlayer
            .environmentObject(voiceMessagePlayer)
    }
    
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 0) {
            Divider()
            
            if viewModel.showPhotoPickerPreview {
                MediaAttachmentPreview(mediaAttachments: viewModel.mediaAttachments) { action in
                    viewModel.handleMediaAttachmentPreview(action)
                }
            }
            
            TextInputArea(
                textMessage: $viewModel.textMessage,
                isRecording: $viewModel.isRecordingVoiceMessage,
                elapsedTime: $viewModel.elapsedVoiceMessageTime,
                disableSendButton: viewModel.disableSendButton) { action in
                    viewModel.handleTextInputArea(action)
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

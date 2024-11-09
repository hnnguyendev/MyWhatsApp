//
//  ChatsTabScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI

struct ChannelsTabScreen: View {
    @State private var searchText = ""
    @StateObject private var viewModel = ChannelTabViewModel()
    
    var body: some View {
        /// switch from NavigationLink to .navigationDestination -> pass path parameter to NavigationStack
        NavigationStack(path: $viewModel.navRoutes) {
            List {
                archivedButton()
                
                ForEach(viewModel.channels) { channel in
                    /// We're using navigation link it's actually initializing this ChatRoomScreen and that is obviously problematic
                    /// We want some sort of a lazy initialization we don't want to touch this initialize this ChatRoomScreen, we don't want to load it into memory until we actually navigate to it
                    /// It mean before we navigate to a ChatRoomScreen, it's already loaded into memory and that's obviously problematic
                    /// We only want to load into memory when we actually navigate into it -> So we're going to switch from NavigationLink to .navigationDestination
//                    NavigationLink {
//                        ChatRoomScreen(channel: channel)
//                    } label: {
//                        ChannelItemView(channel: channel)
//                    }
                    Button {
                        viewModel.navRoutes.append(.chatRoom(channel))
                    } label: {
                        ChannelItemView(channel: channel)
                    }
                }
                
                inboxFooterView()
                    .listRowSeparator(.hidden)
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .listStyle(PlainListStyle())
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            /// switch from NavigationLink to .navigationDestination
            .navigationDestination(for: ChannelTabRoutes.self) { route in
                destinationView(for: route)
            }
            .sheet(isPresented: $viewModel.showChatPartnerPickerView) {
                ChatPartnerPickerScreen(onCreate: viewModel.onNewChannelCreation)
            }
            .navigationDestination(isPresented: $viewModel.navigateToChatRoom) {
                if let newChannel = viewModel.newChannel {
                    ChatRoomScreen(channel: newChannel)
                }
            }
        }
    }
}

extension ChannelsTabScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    
                } label: {
                    Label("Select chats", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            aiButton()
            cameraButton()
            newChatButton()
        }
    }
    
    private func aiButton() -> some View {
        Button {
            
        } label: {
            Image(.circle)
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera")
        }
    }
    
    private func newChatButton() -> some View {
        Button {
            viewModel.showChatPartnerPickerView = true
        } label: {
            Image(.plus)
        }
    }
    
    private func archivedButton() -> some View {
        Button {
            
        } label: {
            Label("Archived", systemImage: "archivebox.fill")
                .bold()
                .padding()
                .foregroundStyle(.gray)
        }
    }
    
    private func inboxFooterView() -> some View {
        HStack {
            Image(systemName: "lock")
            
            (
                Text("Your personal message are ")
                +
                Text("end-to-end encrypted")
                    .foregroundColor(.blue)
            )
        }
        .foregroundStyle(.gray)
        .font(.caption)
        .padding(.horizontal)
    }
    
    /// switch from NavigationLink to .navigationDestination
    @ViewBuilder
    private func destinationView(for route: ChannelTabRoutes) -> some View {
        switch route {
        case .chatRoom(let channel):
            ChatRoomScreen(channel: channel)
        }
    }
}

#Preview {
    ChannelsTabScreen()
}

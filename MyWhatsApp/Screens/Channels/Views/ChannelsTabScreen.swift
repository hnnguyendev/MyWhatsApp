//
//  ChatsTabScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI

struct ChannelsTabScreen: View {
    @State private var searchText = ""
    @State private var showChatPartnerPickerView = false
    
    var body: some View {
        NavigationStack {
            List {
                archivedButton()
                
                ForEach(0..<2) { _ in
                    NavigationLink {
                        ChatRoomScreen()
                    } label: {
                        ChannelItemView()
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
            .sheet(isPresented: $showChatPartnerPickerView) {
                ChatPartnerPickerScreen()
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
            showChatPartnerPickerView = true
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
}

#Preview {
    ChannelsTabScreen()
}

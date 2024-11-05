//
//  ChatPartnerPickerScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 1/11/24.
//

import SwiftUI

struct ChatPartnerPickerScreen: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatPartnerPickerViewModel()
    
    var onCreate: (_ newChannel: ChannelItem) -> Void
    
    var body: some View {
        NavigationStack(path: $viewModel.navStack) {
            List {
                ForEach(ChatPartnerPickerOption.allCases) { item in
                    HeaderItemView(item: item) {
                        guard item == ChatPartnerPickerOption.newGroup else { return }
                        viewModel.navStack.append(.groupPartnerPicker)
                    }
                }
                
                Section {
                    ForEach(viewModel.users) { user in
                        ChatPartnerRowView(user: user)
                            .onTapGesture {
                                viewModel.selectedChatPartners.append(user)
                                let channelCreated = viewModel.createChannel(nil)
                                switch channelCreated {
                                case .success(let channelItem):
                                    onCreate(channelItem)
                                case .failure(let error):
                                    print("Failed to create channel: \(error.localizedDescription)")
                                }
                            }
                    }
                } header: {
                    Text("Contacts on MyWhatsApp")
                        .textCase(nil)
                        .bold()
                }
                
                if viewModel.isPaginable {
                    loadMoreUsersView()
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always), /// Fix search bar not show
                prompt: "Search name or number"
            )
            .navigationTitle("New Chat")
            .navigationDestination(for: ChannelCreationRoute.self) { route in
                destinationView(for: route)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                trailingNavItem()
            }
        }
    }
    
    private func loadMoreUsersView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension ChatPartnerPickerScreen {
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupPartnerPicker:
            GroupPartnerPickerScreen(viewModel: viewModel)
        case .setUpGroupChat:
            NewGroupSetUpScreen(viewModel: viewModel)
        }
    }
}

extension ChatPartnerPickerScreen {
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            cancelButton()
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.footnote)
                .bold()
                .foregroundStyle(.gray)
                .padding(8)
                .background(Color(.systemGray5))
                .clipShape(Circle())
            
        }
    }
}

extension ChatPartnerPickerScreen {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOption
        let onTapHandler: () -> Void
        
        var body: some View {
            Button {
                onTapHandler()
            } label: {
                buttonBody()
            }
        }
        
        private func buttonBody() -> some View {
            HStack {
                Image(systemName: item.imageName)
                    .font(.footnote)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                
                Text(item.title)
            }
        }
    }
}

/// CaseIterable property .allCases called all cases
/// Identifiable -> could use it as a for each as a data source
enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"
    
    /// Need this code for Identifiable
    var id: String {
        return rawValue
    }
    
    var title: String {
        return rawValue
    }
    
    var imageName: String {
        switch self {
        case .newGroup:
            return "person.2.fill"
        case .newContact:
            return "person.fill.badge.plus"
        case .newCommunity:
            return "person.3.fill"
        }
    }
}

#Preview {
    ChatPartnerPickerScreen { channel in
        
    }
}

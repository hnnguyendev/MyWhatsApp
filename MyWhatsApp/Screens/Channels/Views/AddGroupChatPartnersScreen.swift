//
//  AddGroupChatPartnersScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 2/11/24.
//

import SwiftUI

struct AddGroupChatPartnersScreen: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    @State private var searchText = ""
    
    var body: some View {
        List {
            if viewModel.showSelectedUsers {
                Text("Users Selected")
            }
            
            Section {
                ForEach([UserItem.placeholder]) { item in
                    Button {
                        viewModel.handleItenSelection(item)
                    } label: {
                        chatPartnerRowView(.placeholder)
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showSelectedUsers)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always), /// Fix search bar not show
            prompt: "Search name or number"
        )
    }
    
    private func chatPartnerRowView(_ user: UserItem) -> some View {
        ChatPartnerRowView(user: .placeholder) {
            Spacer()
            
            let isSelected = viewModel.isUserSelected(user)
            let imageName = isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyleColer = isSelected ? Color.blue : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyleColer)
                .imageScale(.large)
        }
    }
}

#Preview {
    NavigationStack {
        AddGroupChatPartnersScreen(viewModel: ChatPartnerPickerViewModel())
    }
}

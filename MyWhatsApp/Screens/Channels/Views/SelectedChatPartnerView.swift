//
//  SelectedChatPartnerView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 2/11/24.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { user in
                    chatPartnerView(user)
                }
            }
        }
    }
    
    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack {
            CircularProfileImageView(user.profileImageUrl, size: .medium)
                .overlay(alignment: .topTrailing) {
                    cancelButton(user)
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton(_ user: UserItem) -> some View {
        Button {
            onTapHandler(user)
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
                .background(Color(.systemGray2))
                .clipShape(Circle())
        }
    }
}

#Preview {
    SelectedChatPartnerView(users: UserItem.placeholders) { user in
        
    }
}

//
//  SettingsTabScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    @StateObject private var viewModel: SettingsTabViewModel
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self._viewModel = StateObject(wrappedValue: SettingsTabViewModel(currentUser))
    }
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel, currentUser)
                
                Section {
                    SettingsItemView(item: .broadCastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
                
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .alert(isPresent: $viewModel.showProgressHUD, view: viewModel.progressHUDView)
            .alert(isPresent: $viewModel.showSuccessHUD, view: viewModel.successHUDView)
            .alert("Update Your Profile", isPresented: $viewModel.showUserInfoEditor) {
                TextField("Username", text: $viewModel.username)
                TextField("Bio", text: $viewModel.bio)
                Button("Update") {
                    viewModel.updateUsernameAndBio()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your new username or bio")
            }
        }
    }
}

extension SettingsTabScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Sign Out") {
                Task {
                    try? await AuthManager.shared.logout()
                }
            }
            .font(.system(size: 14))
            .foregroundStyle(.red)
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                viewModel.uploadProfilePhoto()
            }
            .bold()
            .disabled(viewModel.disableSaveButton)
        }
    }
}

private struct SettingsHeaderView: View {
    @ObservedObject private var viewModel: SettingsTabViewModel
    private let currentUser: UserItem
    
    init(_ viewModel: SettingsTabViewModel,_ currentUser: UserItem) {
        self.viewModel = viewModel
        self.currentUser = currentUser
    }
    
    var body: some View {
        Section {
            HStack {
                profileImageView()
                
                userInfoTextView()
                    .onTapGesture {
                        viewModel.showUserInfoEditor = true
                    }
            }
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .not(.videos)) {
                SettingsItemView(item: .avatar)
            }
        }
    }
    
    // Add @ViewBuilder because profilePhoto can be nil
    // ViewBuilder allows us to be able to build a dynamic or construct a dynamic component
    // This basically listening for the profilePhoto and SettingsHeaderView has an ObservedObject if our viewModel means it's going to react when something changes inside of out viewModel
    @ViewBuilder
    private func profileImageView() -> some View {
        if let profilePhoto = viewModel.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageUrl, size: .custom(55))
        }
    }
    
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(currentUser.username)
                    .font(.title2)
                
                Spacer()
                
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text(currentUser.bioUnwrapped)
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabScreen(.placeholder)
}

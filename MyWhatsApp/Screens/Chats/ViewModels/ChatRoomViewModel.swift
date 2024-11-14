//
//  ChatRoomViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 8/11/24.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

// ObservableObject because we want to be able to listen to changes
final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    
    /// We're just going to make this a privately set property but we want to be able to access it outside
    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    
    var showPhotoPickerPreview: Bool {
        return !mediaAttachments.isEmpty
    }
    
    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            guard let self = self else { return }
            switch authState {
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
                if self.channel.allMembersFetched {
                    self.getMessages()
                    print("Channel members: \(channel.members.map { $0.username })")
                } else {
                    self.getAllChannelMembers()
                }
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    func sendMessage() {
        guard let currentUser else { return }
        /// Create a weak reference because we're inside of a class and we want to make sure that the automatic reference
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func getMessages() {
        /// First off let's break off this retain cycle by passing a weak self
        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            print("Messages: \(messages.map { $0.text })")
        }
    }
    
    private func getAllChannelMembers() {
        /// I already have current user, and potentially 2 other members (in ChannelTabViewModel -> getChannelMembers() so no need to refetch those
        guard let currentUser = currentUser else { return }
        let membersAllreadyFetched = channel.members.compactMap { $0.uid }
        var membersUidsToFetch = channel.memberUids.filter { !membersAllreadyFetched.contains($0) }
        membersUidsToFetch = membersUidsToFetch.filter { $0 != currentUser.uid }
        
        UserService.getUsers(with: membersUidsToFetch) { [weak self] userNode in
            /// Because we're creating a weak reference here so if for any reason this context doesn't exist, just ignore or exit out of the scope
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
            print("getAllChannelMembers: \(channel.members.map { $0.username })")
        }
    }
    
    func handleTextInputArea(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        }
    }
    
    // We're listening and subscribing to $photoPickerItems publisher
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else { return }
            Task {
                await self.parsePhotoPickerItems(photoItems)
            }
        }
        .store(in: &subscriptions)
    }
    
    // Then we're converting those photoPickerItems objects to a UIImage object using loadTransferable. First we convert it to a Data and then we convert that Data to a UIImage
    
    // Create a data model that can power all media types in our MediaAttachmentPreview component
    // Transfer the movie URL from PhotoPicker to a DataModel that our app can access
    // Generate a thumbnail for the video using the AVAssetImageGenerator
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnailImage = try? await movie.url.generateVideoThumbnail() {
                    let videoAttachment = MediaAttachment(id: UUID().uuidString, type: .video(thumbnailImage, movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                let data = try? await photoItem.loadTransferable(type: Data.self),
                let thumbnail = UIImage(data: data)
                else { return }
                let photoAttachment = MediaAttachment(id: UUID().uuidString, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
}

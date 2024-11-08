//
//  ChannelTabViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 4/11/24.
//

import Foundation
import Firebase

final class ChannelTabViewModel: ObservableObject {
    @Published var navigateToChatRoom = false
    @Published var newChannel: ChannelItem?
    @Published var showChatPartnerPickerView = false
    @Published var channels = [ChannelItem]()
    typealias ChannelId = String
    @Published var channelDictionary: [ChannelId: ChannelItem] = [:]
    
    init() {
        fetchCurrentUserChannels()
    }
    
    func onNewChannelCreation(_ channel: ChannelItem) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    private func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        /// We want to set an active listener to this specific node, we want to be able to know whenever the specific node changes for the currently logged in user
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] (snapshot: DataSnapshot) in
            guard let userChannelDict = snapshot.value as? [String: Any] else { return }
            userChannelDict.forEach { key, value in
                let channelId = key
                self?.getChannel(with: channelId)
            }
        } withCancel: { error in
            print("Failed to get the current user's channelIds: \(error.localizedDescription)")
        }
    }
    
    private func getChannel(with channelId: String) {
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) { [weak self] (snapshot: DataSnapshot) in
            guard let channelDict = snapshot.value as? [String: Any] else { return }
            var channel = ChannelItem(channelDict)
            self?.getChannelMembers(channel) { members in
                channel.members = members
                /// Fix bug duplicate channel -> create channelDictionary, assign channels as a Array
//                self?.channels.append(channel)
                /// I'm storing these arrays, I'm storing this channel inside of a dictionary and using their channelId as the key to be able to access it
                self?.channelDictionary[channelId] = channel
                self?.reloadData()
                print("Channel: \(channel.title)")
            }
        } withCancel: { error in
            print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
        }
    }
    
    private func getChannelMembers(_ channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        /// Why am I getting the first two for a specific channel? Because all that we need to really power a channel is actually just two members that's all the metadata that we need for a channel that we're displaying in chat screen
        /// So almost in every situation we only going to need two members in this specific screen, we only need to get two member information so there's no reason for us to be fetching all of the channel members inside of the ChannelTabViewModel anyway because as you can imagine a channel can have up to 100 members and that's just you know over fetching 
        let channelMemberUids = Array(channel.memberUids.filter { $0 != currentUid }.prefix(2))
        UserService.getUsers(with: channelMemberUids) { userNode in
            completion(userNode.users)
        }
    }
    
    private func reloadData() {
        self.channels = Array(channelDictionary.values)
        self.channels.sort { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
    }
}

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
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] snapshot in
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
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) { [weak self] snapshot in
            guard let channelDict = snapshot.value as? [String: Any] else { return }
            var channel = ChannelItem(channelDict)
            self?.getChannelMembers(channel) { members in
                channel.members = members
                self?.channels.append(channel)
                print("Channel: \(channel.title)")
            }
        } withCancel: { error in
            print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
        }
    }
    
    private func getChannelMembers(_ channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void) {
        UserService.getUsers(with: channel.memberUids) { userNode in
            completion(userNode.users)
        }
    }
}

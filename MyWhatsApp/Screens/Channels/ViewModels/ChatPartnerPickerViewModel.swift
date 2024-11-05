//
//  ChatPartnerPickerViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 2/11/24.
//

import Foundation
import Firebase

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published private(set) var users = [UserItem]()
    
    private var lastCursor: String?
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    var isPaginable: Bool {
        return !users.isEmpty
    }
    
    private var isDirectChannel: Bool {
        return selectedChatPartners.count == 1
    }
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            
            /// Remove the currently loged in user
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            
            self.users.append(contentsOf: fetchedUsers)
            self.lastCursor = userNode.currentCursor
            print("lastCursor: \(lastCursor ?? "") \(users.count)")
        } catch {
            print("💿 Failed to fetch user in ChatPartnerPickerViewModel")
        }
    }
    
    func handleItemSelection(_ user: UserItem) {
        if isUserSelected(user) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == user.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            selectedChatPartners.append(user)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains { $0.uid == user.uid }
        return isSelected
    }
    
//    func buildDirectChannel() async -> Result<ChannelItem, Error> {
//        
//    }
    
    func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatPartners.isEmpty else { return .failure(ChannelCreationError.noChatPartner) }
        
        guard
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
            let currentUid = Auth.auth().currentUser?.uid
        else { return .failure(ChannelCreationError.failedToCreateUniqueIds) }
        
        let timestamp = Date().timeIntervalSince1970
        
        var memberUids = selectedChatPartners.compactMap { $0.uid }
        memberUids.append(currentUid)
        
        var channelDict: [String: Any] = [
            .id: channelId,
            .creationDate: timestamp,
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .adminUids: [currentUid],
            .memberUids: memberUids,
            .membersCount: memberUids.count
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        
        memberUids.forEach { userId in
            /// Keeping an index of the channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }
        
        /// This is the node that make sure that a specific direct channel is unique.
        /// Because before we're going to create any user direct channels we're going to first validate that channelId doesn't belong or doesn't exist inside of this index.
        if isDirectChannel {
            let chatPartner = selectedChatPartners[0]

            /// user-direct-channels/uid/uid/[channelId]
            /// Before we create any direct channel in the future we're first going to check this path using those two uid properties and if those uid exist we know a user already has a direct channel with that specific user
            FirebaseConstants.UserDirectChannelsRef.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannelsRef.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
        }
        
        var newChannelItem = ChannelItem(channelDict)
        newChannelItem.members = selectedChatPartners
        return .success(newChannelItem)
    }
}

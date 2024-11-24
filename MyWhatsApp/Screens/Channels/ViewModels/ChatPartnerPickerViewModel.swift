//
//  ChatPartnerPickerViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 2/11/24.
//

import Foundation
import Firebase
import Combine

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
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Opps!")
    private var subscription: AnyCancellable?
    
    private var lastCursor: String?
    private var currentUser: UserItem?
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    var isPaginable: Bool {
        return !users.isEmpty
    }
    
    var isDirectChannel: Bool {
        return selectedChatPartners.count == 1
    }
    
    init() {
        listenForAuthState()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func listenForAuthState() {
        subscription = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            switch authState {
            case .loggedIn(let loggedInUser):
                self?.currentUser = loggedInUser
                
                Task {
                    await self?.fetchUsers()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 12)
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
    
    func deSelectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedChatPartners.removeAll()
        }
    }
    
    func handleItemSelection(_ user: UserItem) {
        if isUserSelected(user) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == user.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            guard selectedChatPartners.count < ChannelConstants.maxGroupParticipants else {
                let errorMessage = "Sorry, we only allow a maximum of \(ChannelConstants.maxGroupParticipants) participants in a group chat."
                showError(errorMessage)
                return
            }
            selectedChatPartners.append(user)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func createDirectChannel(_ chatPartner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        if selectedChatPartners.isEmpty {
            selectedChatPartners.append(chatPartner)
        }
        
        Task {
            // If existing DM, get the channel
            if let channelId = await verifyIfDirectChannelExists(with: chatPartner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String: Any]
                var directChannel = ChannelItem(channelDict)
                directChannel.members = selectedChatPartners
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                /// is an escaping closure
                completion(directChannel)
            } else {
                /// Create a new DM with the user
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let error):
                    showError("Sorry! Something Went Wrong While We Were Trying to Setup Your Chat")
                    print("Failed to create a Direct Channel: \(error.localizedDescription)")
                }
            }
        }
    }
    
    typealias ChannelId = String
    private func verifyIfDirectChannelExists(with chatParnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannelsRef.child(currentUid).child(chatParnerId).getData(),
                snapshot.exists()
        else { return nil }
        
        let userDirectChannelDict = snapshot.value as! [String: Bool]
        let channelId = userDirectChannelDict.compactMap { $0.key }.first
        return channelId
    }
    
    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            showError("Sorry! Something Went Wrong While We Were Trying to Setup Your Group Chat")
            print("Failed to create a Group Channel: \(error.localizedDescription)")
        }
    }
    
    private func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatPartners.isEmpty else { return .failure(ChannelCreationError.noChatPartner) }
        
        guard
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
            let currentUid = Auth.auth().currentUser?.uid,
            let messageId = FirebaseConstants.ChannelMessagesRef.childByAutoId().key
        else { return .failure(ChannelCreationError.failedToCreateUniqueIds) }
        
        let timestamp = Date().timeIntervalSince1970
        
        var memberUids = selectedChatPartners.compactMap { $0.uid }
        memberUids.append(currentUid)
        
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        
        var channelDict: [String: Any] = [
            .id: channelId,
            .creationDate: timestamp,
            .createdBy: currentUid,
            .lastMessage: newChannelBroadcast,
            .lastMessageType: newChannelBroadcast,
            .lastMessageTimestamp: timestamp,
            .adminUids: [currentUid],
            .memberUids: memberUids,
            .membersCount: memberUids.count
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }
        
        let messageDict: [String: Any] = [
            .type: newChannelBroadcast,
            .timestamp: timestamp,
            .ownerUid: currentUid
        ]
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.ChannelMessagesRef.child(channelId).child(messageId).setValue(messageDict)
        
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
        if let currentUser {
            newChannelItem.members.append(currentUser)
        }
        return .success(newChannelItem)
    }
    
    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
}

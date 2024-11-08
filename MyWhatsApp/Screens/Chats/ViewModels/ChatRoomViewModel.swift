//
//  ChatRoomViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 8/11/24.
//

import Foundation
import Combine

// ObservableObject because we want to be able to listen to changes
final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    private let channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    @Published var currentUser: UserItem?
    
    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { authState in
            switch authState {
                
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
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
    
}

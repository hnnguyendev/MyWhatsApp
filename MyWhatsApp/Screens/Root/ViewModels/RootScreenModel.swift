//
//  RootScreenModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 31/10/24.
//

import Foundation
import Combine

/// Listening for the authentication state in the root screen model
final class RootScreenModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AuthManager.shared.authState.receive(on: DispatchQueue.main)
            .sink {[weak self] lastestAuthState in
                self?.authState = lastestAuthState
            }
    }
}

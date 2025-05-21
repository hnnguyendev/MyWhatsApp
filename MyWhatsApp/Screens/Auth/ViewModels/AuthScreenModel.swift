//
//  AuthScreenModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 30/10/24.
//

import Foundation

/**
 Fixed: Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
 
 Solved: @MainActorc
 */

/// LoginScreen: AuthScreenModel() ->  SignUpScreen
@MainActor
final class AuthScreenModel: ObservableObject {
    
    // MARK: Published Properties
    @Published var isLoading = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Opps!") /// Tuple
    
    // MARK: Computed Properties
    var disableLoginButton: Bool {
        return email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignUpButton: Bool {
        return email.isEmpty || password.isEmpty || username.isEmpty || isLoading
    }
    
    func handleSignUp() async {
        isLoading = true
        do {
            try await AuthManager.shared.createAccount(for: username, with: email, and: password)
        } catch {
            errorState.errorMessage = "Failed to create an account \(error.localizedDescription)"
            errorState.showError = true
            isLoading = false
        }
    }
    
    // Responsible for triggering the AuthProvider
    func handleLogin() async {
        isLoading = true
        do {
            try await AuthManager.shared.login(with: email, and: password)
        } catch {
            errorState.errorMessage = "Failed to login \(error.localizedDescription)"
            errorState.showError = true
            isLoading = false
        }
    }
}

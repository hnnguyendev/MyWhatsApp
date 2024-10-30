//
//  AuthScreenModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 30/10/24.
//

import Foundation

/// LoginScreen: AuthScreenModel() ->  SignUpScreen
final class AuthScreenModel: ObservableObject {
    
    // Mark: Published Properties
    @Published var isLoading = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    // Mark: Computed Properties
    var disableLoginButton: Bool {
        return email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignUpButton: Bool {
        return email.isEmpty || password.isEmpty || username.isEmpty || isLoading
    }
}

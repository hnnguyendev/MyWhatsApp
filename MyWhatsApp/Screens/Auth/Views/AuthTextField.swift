//
//  AuthTextField.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 29/10/24.
//

/**
 SecureField(type.placeholder, text: $text)
 
 Unable to simultaneously satisfy constraints.
     Probably at least one of the constraints in the following list is one you don't want.
     Try this:
         (1) look at each constraint and try to figure out which you don't expect;
         (2) find the code that added the unwanted constraint or constraints and fix it.
 (
     "<NSLayoutConstraint:0x60000219a4e0 'accessoryView.bottom' _UIRemoteKeyboardPlaceholderView:0x1193942e0.bottom == _UIKBCompatInputView:0x119306880.top   (active)>",
     "<NSLayoutConstraint:0x60000219b2a0 'assistantHeight' SystemInputAssistantView.height == 45   (active, names: SystemInputAssistantView:0x104929b40 )>",
     "<NSLayoutConstraint:0x600002177890 'assistantView.bottom' SystemInputAssistantView.bottom == _UIKBCompatInputView:0x119306880.top   (active, names: SystemInputAssistantView:0x104929b40 )>",
     "<NSLayoutConstraint:0x60000219ba70 'assistantView.top' V:[_UIRemoteKeyboardPlaceholderView:0x1193942e0]-(0)-[SystemInputAssistantView]   (active, names: SystemInputAssistantView:0x104929b40 )>"
 )

 Will attempt to recover by breaking constraint
 <NSLayoutConstraint:0x60000219ba70 'assistantView.top' V:[_UIRemoteKeyboardPlaceholderView:0x1193942e0]-(0)-[SystemInputAssistantView]   (active, names: SystemInputAssistantView:0x104929b40 )>

 Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
 The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKitCore/UIView.h> may also be helpful.
 */

import SwiftUI

struct AuthTextField: View {
    let type: InputType
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)
            
            switch type {
            case .password:
                SecureField(type.placeholder, text: $text)
            default:
                TextField(type.placeholder, text: $text)
                    .keyboardType(type.keyboardType)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

extension AuthTextField {
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, _ iconName: String)
        
        var placeholder: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(let placeholder, _):
                return placeholder
            }
        }
        
        var imageName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(_, let iconName):
                return iconName
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthTextField(type: .email, text: .constant(""))
            AuthTextField(type: .password, text: .constant(""))
            AuthTextField(type: .custom("Birthday", "birthday.cake"), text: .constant(""))
        }
    }
}

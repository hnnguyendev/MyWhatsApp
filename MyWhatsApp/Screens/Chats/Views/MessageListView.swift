//
//  MessageListView.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListController
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController()
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {
        
    }
    
}

#Preview {
    MessageListView()
}

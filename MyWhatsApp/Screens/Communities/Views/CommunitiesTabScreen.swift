//
//  CommunitiesTabScreen.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 26/10/24.
//

import SwiftUI

struct CommunitiesTabScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Image(.communities)
                    
                    Group {
                        Text("Stay connected with community")
                            .font(.title2)
                        
                        Text("Communites bring members together in topic-based groups. Any community you're added to will appear here.")
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 5)
                    
                    Button("See example communities >"){}
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    addNewCommunityButton()
                }
                .padding()
            }
            .navigationTitle("Communities")
        }
        
    }
    
    private func addNewCommunityButton() -> some View {
        Button {
            
        } label: {
            Label("New Community", systemImage: "plus")
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.whatsAppWhite)
                .padding(10)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()
        }
       
    }
}

#Preview {
    CommunitiesTabScreen()
}

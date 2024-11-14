//
//  MediaAttachmentPreview.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 12/11/24.
//

import SwiftUI

struct MediaAttachmentPreview: View {
    let mediaAttachments: [MediaAttachment]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
//                audioAttachmentPreview()
                ForEach(mediaAttachments) { attachment in
                    thumbnailImageView(attachment)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: Constants.listHeight)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
    }
    
    private func thumbnailImageView(_ attachment: MediaAttachment) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
                .cornerRadius(5)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    cancelButton()
                }
                .overlay() {
                    playButton("play.fill")
                        .opacity(attachment.type == .video(UIImage(), .stubUrl) ? 1 : 0)
                }
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(5)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func playButton(_ systemName: String) -> some View {
        Button {
            
        } label: {
            Image(systemName: systemName)
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func audioAttachmentPreview() -> some View {
        ZStack {
            LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottom)
            playButton("mic.fill")
                .padding(.bottom, 15)
        }
        .frame(width: Constants.imageDimension * 2, height: Constants.imageDimension)
        .cornerRadius(5)
        .clipped()
        .overlay(alignment: .topTrailing) {
            cancelButton()
        }
        .overlay(alignment: .bottomLeading) {
            Text("Test mp3 file name here")
                .lineLimit(1)
                .font(.caption)
                .padding(2)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
        }
    }
}

extension MediaAttachmentPreview {
    enum Constants {
        static let listHeight: CGFloat = 100
        static let imageDimension: CGFloat = 80
    }
}

#Preview {
    MediaAttachmentPreview(mediaAttachments: [])
}

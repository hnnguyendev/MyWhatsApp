//
//  MediaPickerItem_Types.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 14/11/24.
//

import Foundation
import SwiftUI

// We need to transfer the video data. To do that we are going to be using the Transferable protocal, that's going to help us in converting the video's URL into a SentTransferredFile, which let's copy the movie's URL into out documents directory as a "mov", file by using the importing closure
// Every time we hit up transferRepresentation protocal it's going to return us a URL
struct VideoPickerTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            return .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            let originalFile = receivedTransferredFile.file
            let uniqueFilename = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFilename)
            try FileManager.default.copyItem(at: originalFile, to: copiedFile)
            return .init(url: copiedFile)
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: String
    let type: MediaAttachmentType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let thumbnail):
            return thumbnail
        case .video(let thumbnail, _):
            return thumbnail
        case .audio:
            return UIImage()
        }
    }
    
    var fileURL: URL? {
        switch type {
        case .photo:
            return nil
        case .video(_, let fileURL):
            return fileURL
        case .audio(let voiceURL, _):
            return voiceURL
        }
    }
    
    var audioDuration: TimeInterval? {
        switch type {
        case .audio(_, let duration):
            return duration
        default:
            return nil
        }
    }
}

enum MediaAttachmentType: Equatable {
    case photo(_ thumbnail: UIImage)
    case video(_ thumbnail: UIImage, _ url: URL)
    case audio(_ url: URL, _ duration: TimeInterval)
    
    static func == (leftHandSide: MediaAttachmentType, rightHandSide: MediaAttachmentType) -> Bool {
        switch(leftHandSide, rightHandSide) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
        default:
            return false
        }
    }
}

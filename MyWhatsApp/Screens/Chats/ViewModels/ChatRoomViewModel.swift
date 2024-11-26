//
//  ChatRoomViewModel.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 8/11/24.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

// ObservableObject because we want to be able to listen to changes
final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    @Published var isRecordingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)
    @Published var isPaginating = false
    private var currentPage: String?
    private var firstMessage: MessageItem?
    
    /// We're just going to make this a privately set property but we want to be able to access it outside
    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private let voiceRecorderService = VoiceRecorderService()
    
    var showPhotoPickerPreview: Bool {
        return !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }
    
    var disableSendButton: Bool {
        return mediaAttachments.isEmpty && textMessage.isEmptyOrWhiteSpace
    }
    
    private var isPreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setupVoiceRecorderListeners()
        
        if isPreviewMode {
            messages = MessageItem.stubMessages
        }
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        /// Remove all recorder when leaving chat room
        voiceRecorderService.tearDown()
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            guard let self = self else { return }
            switch authState {
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
                if self.channel.allMembersFetched {
                    self.getHistoricalMessages()
                    print("Channel members: \(channel.members.map { $0.username })")
                } else {
                    self.getAllChannelMembers()
                }
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    func sendMessage() {
        if mediaAttachments.isEmpty {
            sendTextMessage(textMessage)
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputArea()
        }
    }
    
    private func sendTextMessage(_ text: String) {
        guard let currentUser else { return }
        /// Create a weak reference because we're inside of a class and we want to make sure that the automatic reference
        MessageService.sendTextMessage(to: channel, from: currentUser, text) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func clearTextInputArea() {
        textMessage = ""
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        UIApplication.dismissKeyboard()
    }
    
    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        /// Fix bug text message in each attachment, just in 1 attachment
        for (index, attachment) in attachments.enumerated() {
            let textMessage = index == 0 ? text : ""
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: textMessage, attachment)
            case .video:
                sendVideoMessage(text: textMessage, attachment)
            case .audio:
                sendVoiceMessage(text: textMessage, attachment)
            }
        }
//        mediaAttachments.forEach { attachment in
//            switch attachment.type {
//            case .photo:
//                sendPhotoMessage(text: text, attachment)
//            case .video:
//                sendVideoMessage(text: text, attachment)
//            case .audio:
//                sendVoiceMessage(text: text, attachment)
//            }
//        }
    }
    
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        /// Upload the image to storage bucket
        uploadImageToStorage(attachment) { [weak self] imageURL in
            /// Store the metadata to database
            guard let self = self, let currentUser else { return }
            print("Uploaded Image to Storage")
            
            let uploadParams = MessageUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailUrl: imageURL.absoluteString,
                sender: currentUser
            )
            
            MessageService.sendMediaMessage(to: channel, params: uploadParams) { [weak self] in
                /// TODO: Scroll to bottom upon image upload success
                print("Uploaded Photo to Database")
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        /// Upload the video file to the storage bucket
        uploadFileToStorage(for: .videoMessage, attachment) { [weak self] videoURL in
            /// Upload the video thumbnail
            self?.uploadImageToStorage(attachment, completion: { [weak self] imageURL in
                guard let self = self, let currentUser else { return }
                
                let uploadParams = MessageUploadParams(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailUrl: imageURL.absoluteString,
                    videoUrl: videoURL.absoluteString,
                    sender: currentUser
                )
                
                MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                    print("Uploaded Video to Database")
                    self?.scrollToBottom(isAnimated: true)
                }
            })
        }
    }
    
    private func sendVoiceMessage(text: String, _ attachment: MediaAttachment) {
        /// Upload the audio file to the storage bucket
        guard let audioDuration = attachment.audioDuration, let currentUser else { return }
        uploadFileToStorage(for: .voiceMessage, attachment) { [weak self] audioURL in
            guard let self else { return }
            
            let uploadParams = MessageUploadParams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                audioUrl: audioURL.absoluteString,
                audioDuration: audioDuration,
                sender: currentUser
            )
            
            MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                print("Uploaded Audio to Database")
                self?.scrollToBottom(isAnimated: true)
            }
            
            if !text.isEmptyOrWhiteSpace {
                self.sendTextMessage(text)
            }
        }
    }
    
    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }
    
    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping(_ imageURL: URL) -> Void) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case .success(let imageURL):
                completion(imageURL)
            case .failure(let error):
                print("Failed to upload Image to Storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("UPLOAD IMAGE PROGRESS: \(progress)")
        }
    }
    
    private func uploadFileToStorage(
        for uploadType: FirebaseHelper.UploadType,
        _ attachment: MediaAttachment,
        completion: @escaping(_ fileURL: URL) -> Void) {
            guard let fileToUpload = attachment.fileURL else { return }
            FirebaseHelper.uploadFile(fileURL: fileToUpload, for: uploadType) { result in
                switch result {
                case .success(let fileURL):
                    completion(fileURL)
                case .failure(let error):
                    print("Failed to upload File to Storage: \(error.localizedDescription)")
                }
            } progressHandler: { progress in
                print("UPLOAD FILE PROGRESS: \(progress)")
            }
            
        }
    
    // MARK: /* Deprecated */
    private func getMessages_() {
        /// First off let's break off this retain cycle by passing a weak self
        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            self?.scrollToBottom(isAnimated: false)
            print("Messages: \(messages.map { $0.text })")
        }
    }
    
    private func getHistoricalMessages() {
        isPaginating = currentPage != nil
        MessageService.getHistoricalMessages(for: channel, lastCursor: currentPage, pageSize: 100) { [weak self] messageNode in
            /// If it's the initial data pull
            if self?.currentPage == nil {
                self?.getFirstMessage()
                self?.listenForNewMessages()
            }
            
            self?.messages.insert(contentsOf: messageNode.messages, at: 0)
            self?.currentPage = messageNode.currentCursor
            self?.scrollToBottom(isAnimated: false)
            self?.isPaginating = false
        }
    }
    
    func paginateMoreMessages() {
        guard isPaginatable else {
            isPaginating = false
            return
        }
        getHistoricalMessages()
    }
    
    private func getFirstMessage() {
        MessageService.getFirstMessage(in: channel) { [weak self] firstMessage in
            self?.firstMessage = firstMessage
            print("getFirstMessage: \(firstMessage.id)")
        }
    }
    
    private func listenForNewMessages() {
        MessageService.listenForNewMessages(in: channel) { [weak self] newMessage in
            self?.messages.append(newMessage)
            self?.scrollToBottom(isAnimated: false)
        }
    }
    
    var isPaginatable: Bool {
        return currentPage != firstMessage?.id
    }
    
    private func getAllChannelMembers() {
        /// I already have current user, and potentially 2 other members (in ChannelTabViewModel -> getChannelMembers() so no need to refetch those
        guard let currentUser = currentUser else { return }
        let membersAllreadyFetched = channel.members.compactMap { $0.uid }
        var membersUidsToFetch = channel.memberUids.filter { !membersAllreadyFetched.contains($0) }
        membersUidsToFetch = membersUidsToFetch.filter { $0 != currentUser.uid }
        
        UserService.getUsers(with: membersUidsToFetch) { [weak self] userNode in
            /// Because we're creating a weak reference here so if for any reason this context doesn't exist, just ignore or exit out of the scope
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getHistoricalMessages()
            print("getAllChannelMembers: \(channel.members.map { $0.username })")
        }
    }
    
    func handleTextInputArea(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        }
    }
    
    // We're listening and subscribing to $photoPickerItems publisher
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else { return }
//            self.mediaAttachments.removeAll()
            /// Include removeAll() Photos and Videos
            let audioRecordings = mediaAttachments.filter({ $0.type == .audio(.stubURL, .stubTimeInterval) })
            self.mediaAttachments = audioRecordings
            Task {
                await self.parsePhotoPickerItems(photoItems)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func toggleAudioRecorder() {
        if voiceRecorderService.isRecording {
            voiceRecorderService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            voiceRecorderService.startRecording()
        }
    }
    
    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    // Then we're converting those photoPickerItems objects to a UIImage object using loadTransferable. First we convert it to a Data and then we convert that Data to a UIImage
    
    // Create a data model that can power all media types in our MediaAttachmentPreview component
    // Transfer the movie URL from PhotoPicker to a DataModel that our app can access
    // Generate a thumbnail for the video using the AVAssetImageGenerator
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnailImage = try? await movie.url.generateVideoThumbnail(),
                   let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await photoItem.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = photoItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
    
    func dismissVideoPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    func showMediPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handleMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediPlayer(fileURL)
        case .remove(let attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if (attachment.type == .audio(.stubURL, .stubTimeInterval)) {
                voiceRecorderService.deleteRecoding(at: fileURL)
            }
        }
    }
    
    private func remove(_ attachment: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == attachment.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let pickerItemIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == attachment.id }) else { return }
        photoPickerItems.remove(at: pickerItemIndex)
    }
    
    private func setupVoiceRecorderListeners() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecordingVoiceMessage = isRecording
            }.store(in: &subscriptions)
        
        voiceRecorderService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elaspedTime in
                self?.elapsedVoiceMessageTime = elaspedTime
            }.store(in: &subscriptions)
    }
    
    func isNewDay(for message: MessageItem, at index: Int) -> Bool {
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        return !message.timestamp.isSameDay(as: priorMessage.timestamp)
    }
    
    func showSenderName(for message: MessageItem, at index: Int) -> Bool {
        guard channel.isGroupChat else { return false }
        /// Show only when it's a group chat & when it's not sent by current user
        let isNewDay = isNewDay(for: message, at: index)
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        
        if isNewDay {
            /// If is not sent by current user & is a group chat
            return !message.isSentByMe
        } else {
            /// If is not sent by current user & is a group chat & the message before this one is not sent by the same sender
            return !message.isSentByMe && !message.containsSameOwner(as: priorMessage)
        }
    }
}

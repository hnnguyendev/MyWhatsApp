//
//  VoiceMessagePlayer.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 20/11/24.
//

import Foundation
import AVFoundation

// VoiceMessagePlayer is an ObservableObject, we can think of it as almost a viewModel, that means we can be able to listen and react to changes in it's properties and this VoiceMessagePlayer we're declaring it as a StateObject inside of our ChatRoomScreen, and this "viewModel" is just responsible for playing voice messages. and all we are doing inside of this 
final class VoiceMessagePlayer: ObservableObject {
    private var player: AVPlayer?
    private(set) var currentURL: URL?
    private var playerItem: AVPlayerItem?
    @Published private(set) var playbackState = PlaybackState.stopped
    @Published private(set) var currentTime = CMTime.zero
    private var currentTimeObserve: Any?
    
    deinit {
        tearDown()
    }
    
    func playAudio(from url: URL) {
        if let currentURL = currentURL, currentURL == url {
            resumePlaying()
        } else {
            stopAudioPlayer()
            currentURL = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayBack()
        }
    }
    
    func pauseAudio() {
        player?.pause()
        playbackState = .paused
    }
    
    func seek(to timeInterval: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    // MARK: - Private Methods
    private func resumePlaying() {
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .paused
        }
    }
    
    private func observeCurrentPlayerTime() {
        currentTimeObserve = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            self?.currentTime = time
            print("observeCurrentPlayerTime: \(time)")
        }
    }
    
    private func observeEndOfPlayBack() {
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.stopAudioPlayer()
            print("observeEndOfPlayBack")
        }
    }
    
    private func stopAudioPlayer() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }
    
    private func removeObservers() {
        guard let currentTimeObserve else { return }
        player?.removeTimeObserver(currentTimeObserve)
        self.currentTimeObserve = nil
        print("removeObservers fired")
    }
    
    private func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentURL = nil
    }
}

extension VoiceMessagePlayer {
    enum PlaybackState {
        case stopped, playing, paused
        var icon: String {
            return self == .playing ? "pause.fill" : "play.fill"
        }
    }
}

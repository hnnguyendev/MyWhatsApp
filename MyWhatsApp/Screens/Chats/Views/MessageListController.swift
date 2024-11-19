//
//  MessageListController.swift
//  MyWhatsApp
//
//  Created by Nguyen Huu Nghia on 27/10/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    
    // MARK: View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
        setupMessageListeners()
    }
    
    init(_ viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        /// This is just UIKit boiler plate code
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    private let viewModel: ChatRoomViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCells"
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: .chatbackground)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }()
    
    // MARK: Methods
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    /// We want to get messages information and use it to refresh our list, using combine
    private func setupMessageListeners() {
        let delay = 200
        viewModel.$messages
        /// Just delay and then we want to recieve it on the main thread, we don't want to reload data or refresh UI views on the background thread
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
        /// Just meaning we want to receive those messages
        /// Because this is going to be creating a strong reference let break that by making it [weak self]
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.tableView.scrollToLastRow(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension MessageListController: UITableViewDelegate, UITableViewDataSource {
    /// Use a UIKit tableView, use a SwiftUI view as the cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        cell.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let message = viewModel.messages[indexPath.row]
        
        /// Config SwiftUI into UIKit
        cell.contentConfiguration = UIHostingConfiguration {
            switch message.type {
            case .text:
                BubbleTextView(item: message)
            case .photo, .video:
                BubbleImageView(item: message)
            case .audio:
                BubbleAudioView(item: message)
            case .admin(let adminType):
                switch adminType {
                case .channelCreation:
                    ChannelCreationTextView()
                    
                    if viewModel.channel.isGroupChat {
                        AdminMessageTextView(channel: viewModel.channel)
                    }
                default:
                    Text("UNKNOWN")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("didSelectRowAt: \(indexPath.row)")
        UIApplication.dismissKeyboard()
        let messageItem = viewModel.messages[indexPath.row]
        switch messageItem.type {
        case .video:
            guard let videoUrlString = messageItem.videoUrl,
                  let videoUrl = URL(string: videoUrlString)
            else { return }
            viewModel.showMediPlayer(videoUrl)
        case .audio:
            guard let audioUrlString = messageItem.audioUrl,
                  let audioUrl = URL(string: audioUrlString)
            else { return }
            viewModel.showMediPlayer(audioUrl)
        default:
            break
        }
    }
    
}

private extension UITableView {
    func scrollToLastRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard numberOfRows(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSessionIndex = numberOfSections - 1
        let lastRowIndex = numberOfRows(inSection: lastSessionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSessionIndex)
        scrollToRow(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
        .ignoresSafeArea()
}

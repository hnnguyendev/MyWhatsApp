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
        // Converting TableView to CollectionView
        messagesCollectionView.backgroundColor = .clear
//        tableView_.backgroundColor = .clear
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
    private var lastScrollPosition: String?
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefresh
    }()
    
    // Converting TableView to CollectionView
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        listConfig.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        /// This is going to reduce inter item spacing
        section.interGroupSpacing = -10
        return section
    }
    
    // Converting TableView to CollectionView
    /// Anonymous closure
    /// Reason we're able to directly just passing our compositionalLayout because this is a lazy variable. It's just a variable does not initialized until the first time it is used so that allows us to be able to access our class properties
    private lazy var messagesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()
    
    // MARK: /* Deprecated */
    private lazy var tableView_: UITableView = {
        let tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
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
    
    // Converting TableView to CollectionView
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(messagesCollectionView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: /* Deprecated */
    private func setUpViews_() {
        view.addSubview(backgroundImageView)
        view.addSubview(tableView_)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView_.topAnchor.constraint(equalTo: view.topAnchor),
            tableView_.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView_.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView_.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView_.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    // Converting TableView to CollectionView
    /// We want to get messages information and use it to refresh our list, using combine
    private func setupMessageListeners() {
        let delay = 200
        viewModel.$messages
        /// Just delay and then we want to recieve it on the main thread, we don't want to reload data or refresh UI views on the background thread
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
        /// Just meaning we want to receive those messages
        /// Because this is going to be creating a strong reference let break that by making it [weak self]
            .sink { [weak self] _ in
                self?.messagesCollectionView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }
            .store(in: &subscriptions)
        
        /// I wanna know when we are done paginating and then i want to scroll to the first item that we were at before we pull to refresh
        viewModel.$isPaginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                guard let self = self, let lastScrollPosition else { return }
                if isPaginating == false {
                    guard let index = viewModel.messages.firstIndex(where: { $0.id == lastScrollPosition }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messagesCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }
            }
            .store(in: &subscriptions)
    }
    
    // MARK: /* Deprecated */
    private func setupMessageListeners_() {
        let delay = 200
        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView_.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.tableView_.scrollToLastRow(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }
            .store(in: &subscriptions)
    }
    
    @objc private func refreshData() {
        lastScrollPosition = viewModel.messages.first?.id
        viewModel.getMessages()
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
//extension MessageListController: UITableViewDelegate, UITableViewDataSource {

// Converting TableView to CollectionView
// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    // Converting TableView to CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        
        let message = viewModel.messages[indexPath.item]
        let isNewDay = viewModel.isNewDay(for: message, at: indexPath.item)
        let showSenderName = viewModel.showSenderName(for: message, at: indexPath.item)
        
        /// Config SwiftUI into UIKit
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(message: message, channel: viewModel.channel, isNewDay: isNewDay, showSenderName: showSenderName)
        }
        return cell
    }
    
    // Converting TableView to CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    // Converting TableView to CollectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
        let messageItem = viewModel.messages[indexPath.row]
        switch messageItem.type {
        case .video:
            guard let videoUrlString = messageItem.videoUrl,
                  let videoUrl = URL(string: videoUrlString)
            else { return }
            viewModel.showMediPlayer(videoUrl)
        default:
            break
        }
    }
    
    /// Use a UIKit tableView, use a SwiftUI view as the cell
    // MARK: /* Deprecated */
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
    
    // MARK: /* Deprecated */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    // MARK: /* Deprecated */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: /* Deprecated */
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

// Converting TableView to CollectionView
private extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSessionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSessionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSessionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

// MARK: /* Deprecated */
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

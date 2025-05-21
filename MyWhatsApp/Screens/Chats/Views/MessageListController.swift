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
        setUpLongPressGestureRecognizer()
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
    
    // MARK: Custom Reactions Properties
    private var startingFrame: CGRect?
    private var blurView: UIVisualEffectView?
    private var focusedView: UIView?
    private var highlightedCell: UICollectionViewCell?
    private var reactionHostVC: UIViewController?
    private var messageMenuHostVC: UIViewController?
    
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
    
    private let pullDownHUDView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = .bubbleGreen
        buttonConfig.baseForegroundColor = .whatsAppBlack
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfig.attributedTitle = AttributedString("Pull Down", attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    // MARK: Methods
    
    // Converting TableView to CollectionView
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(messagesCollectionView)
        view.addSubview(pullDownHUDView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pullDownHUDView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pullDownHUDView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        viewModel.paginateMoreMessages()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            pullDownHUDView.alpha = viewModel.isPaginatable ? 1 : 0
        } else {
            pullDownHUDView.alpha = 0
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

// MARK: Extensions

extension MessageListController {
    @objc private func showContextMenu(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: messagesCollectionView)
        
        guard let indexPath = messagesCollectionView.indexPathForItem(at: point) else { return }
        
        let message = viewModel.messages[indexPath.item]
        
        /// Do not show with admin message
        guard message.type.isAdminMessage == false else { return }
        
        guard let selectedCell = messagesCollectionView.cellForItem(at: indexPath) else { return }
        
        Haptic.impact(.medium)
        
//        selectedCell.backgroundColor = .gray
        /// 1. Get the position of the item we're selected and store it
        startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        
        /// 2. Take a screenshot of the item that we have selected
        guard let snapshotCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        
        /// focusedView is sort of like a container that helps us animate the screenshot that we just took
        focusedView = UIView(frame: startingFrame ?? .zero)
        guard let focusedView else { return }
        focusedView.isUserInteractionEnabled = false
//        focusedView.backgroundColor = .systemPink
        
        /// 3. Set up tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContextMenu))
        
        /// 4. Set up blurView
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView else { return }
        blurView.contentView.isUserInteractionEnabled = true
        blurView.contentView.addGestureRecognizer(tapGesture)
        blurView.alpha = 0
        highlightedCell = selectedCell
        highlightedCell?.alpha = 0
        
        guard let keyWindow = UIWindowScene.current?.keyWindow else { return }
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusedView)
        focusedView.addSubview(snapshotCell)
        /// 5. blurView frame
        blurView.frame = keyWindow.frame
        
        let isNewDay = viewModel.isNewDay(for: message, at: indexPath.item)
        attachMenuActionItems(to: message, in: keyWindow, isNewDay)
        
        let shrinkCell = shrinkCell(startingFrame?.height ?? 0)
        
        /// 6. Animate the position of the focusedView, focusedView is sort of like a container that helps us animate the screenshot that we just took
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            blurView.alpha = 1
            focusedView.center.y = keyWindow.center.y - 60
            snapshotCell.frame = focusedView.bounds
            snapshotCell.layer.applyShadow(color: .gray, alpha: 0.2, x: 0, y: 2, blur: 4)
            
            /// Scale down when message too long
            if shrinkCell {
                let xTranslation: CGFloat = message.direction == .received ? -80 : 80
                let translation = CGAffineTransform(translationX: xTranslation, y: 1)
                focusedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(translation)
            }
        }
    }
    
    private func attachMenuActionItems(to message: MessageItem, in window: UIWindow, _ isNewDay: Bool) {
        /// Convert a SwiftUI to UIKit
        guard let focusedView, let startingFrame else { return }
        
        let shrinkCell = shrinkCell(startingFrame.height)
        
        // ReactionPickerView
        let reactionPickerView = ReactionPickerView(message: message) { [weak self] reaction in
            self?.dismissContextMenu()
            self?.viewModel.addReaction(reaction, to: message)
        }
        let reactionHostVC = UIHostingController(rootView: reactionPickerView)
        reactionHostVC.view.backgroundColor = .clear
        reactionHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        var reactionPadding: CGFloat = isNewDay ? 59 : 5
        if shrinkCell {
            reactionPadding += (startingFrame.height / 3)
        }
        
        window.addSubview(reactionHostVC.view)
        /// Bottom of ReactionPickerView == top of focusedView
        reactionHostVC.view.bottomAnchor.constraint(equalTo: focusedView.topAnchor, constant: reactionPadding).isActive = true
        reactionHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        // MessageMenuView
        let messageMenuView = MessageMenuView(message: message)
        let messageMenuHostVC = UIHostingController(rootView: messageMenuView)
        messageMenuHostVC.view.backgroundColor = .clear
        messageMenuHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        var menuPadding: CGFloat = 5
        if shrinkCell {
            menuPadding -= (startingFrame.height / 2.5)
        }
        
        window.addSubview(messageMenuHostVC.view)
        messageMenuHostVC.view.topAnchor.constraint(equalTo: focusedView.bottomAnchor, constant: menuPadding).isActive = true
        messageMenuHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        messageMenuHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.reactionHostVC = reactionHostVC
        self.messageMenuHostVC = messageMenuHostVC
    }
    
    @objc private func dismissContextMenu() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            focusedView?.transform = .identity
            focusedView?.frame = startingFrame ?? .zero
            reactionHostVC?.view.removeFromSuperview()
            messageMenuHostVC?.view.removeFromSuperview()
            blurView?.alpha = 0
        } completion: { [weak self] _ in
            self?.highlightedCell?.alpha = 1
            self?.blurView?.removeFromSuperview()
            self?.focusedView?.removeFromSuperview()
            
            /// Clearing References
            self?.highlightedCell = nil
            self?.blurView = nil
            self?.focusedView = nil
            self?.reactionHostVC = nil
            self?.messageMenuHostVC = nil
        }
    }
    
    private func setUpLongPressGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        longPressGesture.minimumPressDuration = 0.5
        messagesCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func shrinkCell(_ cellHeight: CGFloat) -> Bool {
        let screenHeight = (UIWindowScene.current?.screenHeight ?? 0) / 1.2
        let spacingForMenuView = screenHeight - cellHeight
        return spacingForMenuView < 190
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

extension CALayer {
    func applyShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat,  blur: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = .init(width: x, height: y)
        shadowRadius = blur
        masksToBounds = false
    }
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
        .ignoresSafeArea()
        .environmentObject(VoiceMessagePlayer())
}

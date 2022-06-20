//
//  ChatViewController.swift
//  Messenger
//
//  Created by ineta.magone on 10/06/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MessageKit Framework settings

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var photoUrl: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter = DateFormatter()
    public let otherUserEmail: String
    private let conversationId: String?
    
    public var isNewConversation = false
    private var messages = [Message]()
    //private var testSender: Sender?
    
    private var testSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoUrl: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.dateFormatter = setDateFormatter()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesOfConversation(with: id, completion: { [ weak self ] result in
            switch result {
            case .success(let messages):
                print("Success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("Messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    // Don't scroll down if new message comes
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    } else {
                        
                    }
                }
                
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = testSender {
            return sender
        }
        fatalError("TestSender is nil, email should be cached")
        //return Sender(photoUrl: "", senderId: "123", displayName: "SelfSender")
    }
    
    // MessageKit framework uses 'section' instead of usual 'row'
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let testSender = self.testSender,
              let messageId = createMessageId() else {
            return
        }
        print("Sending \(text)")
        // Send message
        if isNewConversation {
            // create conversation in Firebase
            let message = Message(sender: testSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { success in
                if success {
                    print("Message sent")
                } else {
                    print("Failed to send a message")
                }
            })
        } else {
            // append to existing conversation
            
        }
    }
    
    private func createMessageId() -> String? {
        // random string from date, otherUserEmail and senderEmail, random Int
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newId = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("Created messageId: \(newId)")
        return newId
    }
}

// For item setup
extension ChatViewController {
    
    func setDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }
    
}

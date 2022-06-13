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

struct Sender: SenderType {
    var photoUrl: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter = DateFormatter()
    public let otherUserEmail: String
    public var isNewConversation = false
    private var messages = [Message]()
    //private var testSender: Sender?
    
    private var testSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(photoUrl: "",
                      senderId: email,
                      displayName: "Joe Smith")
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        Self.dateFormatter = setDateFormatter()
        //        guard let email = UserDefaults.standard.value(forKey: "email") else {
        //            return nil
        //        }
        //        testSender = Sender(photoUrl: "",
        //                       senderId: email,
        //                       displayName: "Joe Smith")
        
        
        //        messages.append(Message(sender: testSender,
        //                                messageId: "2",
        //                                sentDate: Date(),
        //                                kind: .text("Hello Message")))
        //        messages.append(Message(sender: testSender,
        //                                messageId: "1",
        //                                sentDate: Date(),
        //                                kind: .text("Hello Message, Hello Message, Hello Message")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = testSender {
            return sender
        }
        fatalError("TestSender is nil, email should be cached")
        return Sender(photoUrl: "", senderId: "123", displayName: "SelfSender")
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
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: { success in
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
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newId = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("Created messageId: \(newId)")
        return newId
    }
}

// For item setup
extension ChatViewController {
    
    func setDateFormatter() -> DateFormatter {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }
    
}

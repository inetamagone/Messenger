//
//  ChatViewController.swift
//  Messenger
//
//  Created by ineta.magone on 10/06/2022.
//

import UIKit
import MessageKit

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
    
    private var messages = [Message]()
    private var testSender = Sender(photoUrl: "",
                                    senderId: "1",
                                    displayName: "Joe Smith")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        messages.append(Message(sender: testSender,
                                messageId: "2",
                                sentDate: Date(),
                                kind: .text("Hello Message")))
        messages.append(Message(sender: testSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello Message, Hello Message, Hello Message")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return testSender
    }
    
    // MessageKit framework uses 'section' instead of usual 'row'
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

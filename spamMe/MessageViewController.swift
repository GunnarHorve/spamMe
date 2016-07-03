//
//  ViewController.swift
//  spamMe
//
//  Created by Gunnar Horve on 6/29/16.
//  Copyright © 2016 Latent Non-Ability. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import FirebaseStorage
import FirebaseDatabase

class MessageViewController: JSQMessagesViewController {
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var ref: FIRDatabaseReference!
    var imagesRef: FIRStorageReference!
    
    // MARK: chat variables
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var chatId: String?
    
    var userIsTypingRef: FIRDatabaseReference!
    private var localTyping = false
    var isTyping: Bool {
        get { return localTyping }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    var usersTypingQuery: FIRDatabaseQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: chat initialization
        self.senderId = "gunnarId"
        self.senderDisplayName = "Gunnar"
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // MARK: firebase initialization
        ref = FIRDatabase.database().reference()
        imagesRef = FIRStorage.storage().referenceForURL("gs://spamme-82aff.appspot.com/images/")
        observeMessages()
        observeTyping()
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    
    // message delegate methods
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    // chat bubble work
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // killing avatars
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // send message work
    func addMessage(id: String, text: String, time: Double, senderDisplayName: String) {
        let message = JSQMessage(senderId: id, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: time), text: text)
        self.messages.append(message)
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
            cell.messageBubbleTopLabel.text = formatTime(message.date.timeIntervalSince1970)
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            cell.messageBubbleTopLabel.text = message.senderDisplayName + " @ " + formatTime(message.date.timeIntervalSince1970)
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat { return 15 }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        let key = ref.child("comments/\(chatId!)").childByAutoId().key
        let post = ["senderId": self.senderId,
                    "body": text,
                    "time": NSDate().timeIntervalSince1970]
        let childUpdates = ["/comments/\(chatId!)/\(key)": post,
                            "/chats/\(chatId!)/lastMSG": key]
        
        ref.updateChildValues(childUpdates)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
    
    // display message work
    private func observeMessages() {
        self.ref.child("comments/\(chatId!)").queryLimitedToLast(25).observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["body"] as! String
            let time = snapshot.value!["time"] as! Double
            self.ref.child("users/\(id)/name").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                let senderDisplayName = snapshot.value as! String
                
                self.addMessage(id, text: text, time: time, senderDisplayName: senderDisplayName)
                self.finishReceivingMessage()
            })
        })
    }
    
    // check if anyone is typing work
    private func observeTyping() {
        let typingIndicatorRef = ref.child("chats/\(chatId!)/typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FIRDataSnapshot!) in
            if data.childrenCount == 1 && self.isTyping { return }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
}

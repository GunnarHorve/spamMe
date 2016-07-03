//
//  ChatViewController.swift
//  spamMe
//
//  Created by Gunnar Horve on 7/2/16.
//  Copyright © 2016 Latent Non-Ability. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import FirebaseStorage
import FirebaseDatabase

class ChatViewController: UITableViewController {
    var ref: FIRDatabaseReference!
    var imagesRef: FIRStorageReference!
    
    var chats = [Chat]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        imagesRef = FIRStorage.storage().referenceForURL("gs://spamme-82aff.appspot.com/images/")
        watchChatsData()
    }
    
    func watchChatsData() {
        // Listen for new comments in the Firebase database
        self.ref.child("users/gunnarId/chats").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            let chatId: String = snapshot.value! as! String
            self.createChatItem(chatId)
        })
    }
    
    func createChatItem(chatId: String) {
        self.ref.child("chats/\(chatId)").observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            let title = snapshot.value!["Title"] as! String
            let msgId = snapshot.value!["lastMSG"] as! String
            self.ref.child("comments/\(chatId)/\(msgId)").observeSingleEventOfType(.Value, withBlock: { (snapshot2) -> Void in
                let body = snapshot2.value!["body"] as! String
                //              let image = snapshot2.value!["imageURL"] as ! Image
                let senderId = snapshot2.value!["senderId"] as! String
                self.ref.child("users/\(senderId)/name").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                    let senderDisplayName = snapshot.value as! String
                    let time = formatTime(snapshot2.value!["time"] as! Double)
                    let timeField = senderDisplayName + " @ " + time
                    self.chats.append(Chat(title: title, time: timeField, preview: body, chatId: chatId))
                })
            })
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatTableViewCell", forIndexPath: indexPath) as! chatTableViewCell
        let row = indexPath.row
        let chat = chats[row]
        
        //cell.chatIcon.image = ??
        cell.titleDisplay.text = chat.title
        cell.timeDisplay.text = chat.time
        cell.previewDisplay.text = chat.preview
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "displayChat" {
                let indexPath = tableView.indexPathForSelectedRow!
                let controller = segue.destinationViewController as! MessageViewController
                controller.chatId = chats[indexPath.row].chatId!
                controller.titleBar.title = chats[indexPath.row].title
            }
        }
    }
}
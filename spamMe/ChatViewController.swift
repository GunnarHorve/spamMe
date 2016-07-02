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
    
    var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        imagesRef = FIRStorage.storage().referenceForURL("gs://spamme-82aff.appspot.com/images/")
        watchChatsData()
        
        //        self.ref.child("users/gunnarId/chats").observeSingleEventOfType(.Value, withBlock: { snapshot in
        //            let enumerator = snapshot.children
        //            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
        //                print(rest.value!)
        //            }
        //        })

    }
    
    func watchChatsData() {
        self.ref.child("users/gunnarId/chats").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                print(rest.value!)
            }
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
}
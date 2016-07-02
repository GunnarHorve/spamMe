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
    
    @IBOutlet weak var titleDisplayLabel: UILabel!
    @IBOutlet weak var timeDisplayLabel: UILabel!
    @IBOutlet weak var messagePreviewLabel: UILabel!
    @IBOutlet weak var chatIconImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        imagesRef = FIRStorage.storage().referenceForURL("gs://spamme-82aff.appspot.com/images/")
        
//        self.ref.child("users/gunnarId/chats").observeSingleEventOfType(.Value, withBlock: { snapshot in
//            let enumerator = snapshot.children
//            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
//                print(rest.value!)
//            }
//        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatTableViewCell", forIndexPath: indexPath) as! chatTableViewCell
        
        cell.titleDisplay.text = "Chat 1"
        cell.timeDisplay.text = "1:00"
        cell.previewDisplay.text = "Top kek"
        //cell.chatIcon.image = ??
        
        return cell
    }
}
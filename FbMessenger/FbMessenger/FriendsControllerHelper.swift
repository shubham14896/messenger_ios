//
//  FriendsControllerHelper.swift
//  FbMessanger
//
//  Created by Shubham Gupta on 3/26/18.
//  Copyright © 2018 Shubham Gupta. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData(){
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            do {
                
                let entityNames = ["ModalFriend","ModalMessage"]
                
                for entity in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try (context.save())
                
            }catch let err{
                print(err)
            }
        }
        
    }
    
    func setupData(){
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let steve  = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
            steve.name = "Steve Jobs"
            steve.profileImage = "steve"
            
            FriendsController.createMessageWithText(text: "Good Morning", friend: steve, minutesAgo: 3, context: context)
//            FriendsController.createMessageWithText(text: "Hello How are you , Hope yor having a good morning !", friend: steve, minutesAgo: 2, context: context)
//            FriendsController.createMessageWithText(text: "Wassup these days ? , i have been looking for someone to join for the coming weekend Holidays , U free ?", friend: steve, minutesAgo: 1, context: context)
//            FriendsController.createMessageWithText(text: "Yes,what's the plan ?", friend: steve, minutesAgo: 1, context: context , isSender: true)
//            FriendsController.createMessageWithText(text: "Catch up at 8:00 AM Rajiv Metro whats say?", friend: steve, minutesAgo: 1, context: context)
//            FriendsController.createMessageWithText(text: "Hi", friend: steve, minutesAgo: 1, context: context , isSender: true)
//            FriendsController.createMessageWithText(text: "Done! See you soon buddy", friend: steve, minutesAgo: 1, context: context)
//            FriendsController.createMessageWithText(text: "Thanks", friend: steve, minutesAgo: 1, context: context)
            
            let gandhi  = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImage = "gandhi"
            
//            FriendsController.createMessageWithText(text: "Love, Peace and Joy", friend: gandhi, minutesAgo: 60 * 24, context: context)
            
            let hillary  = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
            hillary.name = "Hillary Clinton"
            hillary.profileImage = "hillary_profile"
            
            FriendsController.createMessageWithText(text: "Please Vote for me", friend: hillary, minutesAgo: 8 * 60 * 24, context: context)
            
            let mark = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
            mark.name = "Mark Zuckerberg"
            mark.profileImage = "mark"
            
            FriendsController.createMessageWithText(text: "Hello, my name is Mark, Nice to meet you...", friend: mark, minutesAgo: 2, context: context)
            
            do {
                try(context.save())
            }catch let err{
                print(err)
            }
        }
    }
    
    static func createMessageWithText(text: String, friend: ModalFriend, minutesAgo: Double, context: NSManagedObjectContext , isSender: Bool = false){
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "ModalMessage", into: context) as! ModalMessage
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        
        friend.lastMessage = message
    }
}

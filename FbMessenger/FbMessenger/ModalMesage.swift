//
//  ModalMesage.swift
//  FbMessanger
//
//  Created by Shubham Gupta on 3/26/18.
//  Copyright © 2018 Shubham Gupta. All rights reserved.
//


import Foundation
import CoreData

@objc(ModalMessage)

public class ModalMessage: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ModalMessage> {
        return NSFetchRequest<ModalMessage>(entityName: "ModalMessage")
    }
    
    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var messages: ModalFriend?
}

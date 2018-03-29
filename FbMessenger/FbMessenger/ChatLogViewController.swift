//
//  ChatLogViewController.swift
//  FbMessanger
//
//  Created by Shubham Gupta on 3/27/18.
//  Copyright © 2018 Shubham Gupta. All rights reserved.
//

import UIKit
import CoreData

class ChatLogViewController : UICollectionViewController , UICollectionViewDelegateFlowLayout , NSFetchedResultsControllerDelegate{
    
    private let cellId = "cellId"
    
    var friend: ModalFriend?{
        didSet{
            navigationItem.title = friend?.name
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend(){
//            print(inputTextField.text!)
        
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            
            FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
            
            do{
                try context.save()
                inputTextField.text = nil
                
            }catch let err{
                print(err)
            }
    }
    
    var bottomConstraint: NSLayoutConstraint?

    @objc func simulate(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        FriendsController.createMessageWithText(text: "Hey There How are you", friend: friend!, minutesAgo: 1, context: context)
        
        FriendsController.createMessageWithText(text: "Hey There  Wassup", friend: friend!, minutesAgo: 1, context: context)
     
        do{
            try context.save()
        
        }catch let err{
            print(err)
        }
    }
    
    
    lazy var fetchResultsContoller: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModalMessage")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"date",ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend!.name!)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
       return frc
        
    }()
    
    var blockOperations = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
               self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            
            for operation in self.blockOperations {
                operation.start()
            }
            
        }, completion: { (completed) in
            
            let lastItem = self.fetchResultsContoller.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    override func viewDidLoad(){
        
        do {
            try fetchResultsContoller.performFetch()
        }catch let err{
            print(err)
        }
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainerView)
        
        view.addConstraintsWithView(format: "H:|[v0]|", view: messageInputContainerView)
        view.addConstraintsWithView(format: "V:[v0(48)]", view: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        
        view.addConstraint(bottomConstraint!)
        
        tabBarController?.tabBar.layer.zPosition = -1
        tabBarController?.tabBar.isHidden = true
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatLogViewController.handleKeyboardNotification), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatLogViewController.handleKeyboardNotification), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
//            print((keyboardFrame?.cgRectValue)!)
            
            let isKeyboardShowing = notification.name == Notification.Name.UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame?.cgRectValue.height)! : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    let lastItem = self.fetchResultsContoller.sections![0].numberOfObjects - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func setupInputComponents(){
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        messageInputContainerView.addConstraintsWithView(format: "H:|-8-[v0][v1(60)]|", view: inputTextField,sendButton)
        
        messageInputContainerView.addConstraintsWithView(format: "V:|[v0]|", view: inputTextField)
        messageInputContainerView.addConstraintsWithView(format: "V:|[v0]|", view: sendButton)
        
        messageInputContainerView.addConstraintsWithView(format: "H:|[v0]|", view: topBorderView)
        messageInputContainerView.addConstraintsWithView(format: "V:|[v0(0.5)]", view: topBorderView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchResultsContoller.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = fetchResultsContoller.object(at: indexPath) as! ModalMessage
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        cell.mTextView.text = message.text
        
        if let messageText = message.text , let profileImageName = message.friend?.profileImage {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if !message.isSender {
                cell.mTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = false
                cell.mTextView.textColor = UIColor.black
                cell.bubbleImageview.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageview.image = ChatLogMessageCell.grayBubbleImage
                
            } else{
                cell.mTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = true
                cell.mTextView.textColor = UIColor.white
                cell.bubbleImageview.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.bubbleImageview.image = ChatLogMessageCell.blueBubbleImage
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = fetchResultsContoller.object(at: indexPath) as! ModalMessage
        
        if let messageText = message.text {
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
}

class ChatLogMessageCell: BaseCell {
    
    let mTextView: UITextView = {
        let tView = UITextView()
        tView.font = UIFont.systemFont(ofSize: 18)
        tView.text = "Sample Message"
        tView.backgroundColor = UIColor.clear
        tView.isUserInteractionEnabled = false
        return tView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    
    let bubbleImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setUpView() {
        super.setUpView()
        addSubview(textBubbleView)
        addSubview(mTextView)
        addSubview(profileImageView)
        
        addConstraintsWithView(format: "H:|-8-[v0(30)]", view: profileImageView)
        addConstraintsWithView(format: "V:[v0(30)]|", view: profileImageView)
        
        textBubbleView.addSubview(bubbleImageview)
        textBubbleView.addConstraintsWithView(format:"H:|[v0]|", view: bubbleImageview)
        textBubbleView.addConstraintsWithView(format:"V:|[v0]|", view: bubbleImageview)
        
        profileImageView.backgroundColor = UIColor.red
    }
}

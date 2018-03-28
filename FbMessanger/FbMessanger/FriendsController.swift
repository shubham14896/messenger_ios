//
//  ViewController.swift
//  FbMessanger
//
//  Created by Shubham Gupta on 2/12/18.
//  Copyright © 2018 Shubham Gupta. All rights reserved.
//

import UIKit
import CoreData

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout , NSFetchedResultsControllerDelegate {
    
    private let cellId = "cellId"
    
    lazy var fetchResultsContoller: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModalFriend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"lastMessage.date",ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Recent"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
        
        do {
            try fetchResultsContoller.performFetch()
        } catch let err {
            print(err)
        }
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Chat", style: .plain, target: self, action: #selector(addChat))
    }
    
    @objc func addChat(){
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let mark = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
        mark.name = "Mark Zuckerberg"
        mark.profileImage = "mark"
        
        FriendsController.createMessageWithText(text: "Hello, my name is Mark, Nice to meet you...", friend: mark, minutesAgo: 2, context: context)
        
        let bill = NSEntityDescription.insertNewObject(forEntityName: "ModalFriend", into: context) as! ModalFriend
        bill.name = "Bill Gates"
        bill.profileImage = "mark"
        
        FriendsController.createMessageWithText(text: "Hello, Bill Gates Calling", friend: bill, minutesAgo: 2, context: context)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchResultsContoller.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let friend = fetchResultsContoller.object(at: indexPath) as! ModalFriend
        
        cell.message = friend.lastMessage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let Flowlayout = UICollectionViewFlowLayout()
        let controller =  ChatLogViewController(collectionViewLayout: Flowlayout)
        let friend = fetchResultsContoller.object(at: indexPath) as! ModalFriend
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
}

class MessageCell : BaseCell{
    
    override var isHighlighted: Bool{
        didSet{
            backgroundColor = isHighlighted ? UIColor.init(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timelabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
        }
    }
    
    var message: ModalMessage?{
        didSet{
            nameLabel.text = message?.friend?.name
            if let pImageName = message?.friend?.profileImage{
                profileImageView.image = UIImage(named: pImageName)
                hasReadImagevIew.image = UIImage(named: pImageName)
            }
            messageLabel.text = message?.text
            
            if let date = message?.date{
                let df = DateFormatter()
                df.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays{
                    df.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondInDays {
                    df.dateFormat = "EEE"
                }                
                timelabel.text = df.string(from: date as Date)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Steve Jobs"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello , Friends How are you what's up these days"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timelabel: UILabel = {
        let label = UILabel()
        label.text = "12:44 AM"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let hasReadImagevIew: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setUpView(){
        
        addSubview(profileImageView)
        addSubview(dividerLine)
        setupContainerView()
        
        profileImageView.image = UIImage(named: "avatar")
        hasReadImagevIew.image = UIImage(named: "avatar")
        
        addConstraintsWithView(format: "H:|-12-[v0(68)]", view: profileImageView)
        addConstraintsWithView(format: "V:[v0(68)]", view: profileImageView)
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithView(format: "H:|-82-[v0]|", view: dividerLine)
        addConstraintsWithView(format: "V:[v0(1)]|", view: dividerLine)
    }
    
    private func setupContainerView(){
        
        let containerView = UIView()
        
        addSubview(containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithView(format:"H:|-90-[v0]|" , view: containerView)
        addConstraintsWithView(format:"V:[v0(50)]" , view: containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timelabel)
        containerView.addSubview(hasReadImagevIew)
        
        containerView.addConstraintsWithView(format:"H:|[v0][v1(80)]-12-|", view: nameLabel,timelabel)
        
        containerView.addConstraintsWithView(format:"V:|[v0][v1(24)]|", view: nameLabel,messageLabel)
        
        containerView.addConstraintsWithView(format:"H:|[v0]-8-[v1(20)]-12-|", view: messageLabel,hasReadImagevIew)
        
        containerView.addConstraintsWithView(format:"V:|[v0(24)]", view: timelabel)
        
        containerView.addConstraintsWithView(format:"V:[v0(20)]|", view: hasReadImagevIew)
    }
}

extension UIView {
    
    func addConstraintsWithView(format: String, view: UIView...){
        
        var viewsDictionary = [String: UIView]()
        
        for(index, view) in view.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpView(){

    }
}


